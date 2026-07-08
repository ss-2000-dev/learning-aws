# 09. DB のデータを CSV ファイルに出力する

DB のデータをターミナルから CSV ファイルとして書き出す方法。
「本番データを確認用に落としたい」「Excel で開きたい」「バックアップ的に残したい」時に使う。

---

## 結論：初心者は `\copy` を使う

CSV 出力には `COPY`（SQL）と `\copy`（psql メタコマンド）があるが、**Aurora では `\copy` を使う**のが正解。理由は下記。

| コマンド | ファイルの出力先 | Aurora での可否 |
|---|---|---|
| `\copy`（メタコマンド） | **手元 / 踏み台の PC** に出力 | ✅ 使える |
| `COPY ... TO 'ファイル'`（SQL） | **DBサーバー上**に出力 | ❌ Aurora はサーバーのファイルに触れないので不可 |

`\copy` は「手元にファイルが欲しい」という目的にそのまま合う。

---

## 基本：テーブルまるごと CSV に出力

psql に接続した状態で実行する。

```
appdb=> \copy users TO 'users.csv' WITH (FORMAT csv, HEADER true)
```

- `users` … 出力するテーブル
- `'users.csv'` … 出力先ファイル（psql を実行している**手元のカレントディレクトリ**にできる）
- `FORMAT csv` … CSV 形式で
- `HEADER true` … 1行目にカラム名（ヘッダー）を入れる

> 💡 出力先は、psql を起動したディレクトリからの相対パス。絶対パスも指定できる：`\copy users TO '/tmp/users.csv' WITH (FORMAT csv, HEADER true)`

---

## SELECT の結果を CSV に出力（実務ではこれが主役）

「特定の条件」「必要な列だけ」「並び替え済み」で出したいことがほとんど。SELECT を `( )` で囲む。

```
appdb=> \copy (SELECT id, name, email FROM users WHERE status = 'active' ORDER BY id) TO 'active_users.csv' WITH (FORMAT csv, HEADER true)
```

集計結果もそのまま出せる：

```
appdb=> \copy (SELECT status, count(*) FROM users GROUP BY status) TO 'user_stats.csv' WITH (FORMAT csv, HEADER true)
```

---

## 接続せずにシェルから一発で出力する

psql に入らず、ターミナルから1コマンドで CSV を作る方法。**スクリプト化・自動化に便利**。

### 方法A：`-c` で \copy を渡す

```bash
psql -h <エンドポイント> -U app_user -d appdb \
  -c "\copy (SELECT * FROM users WHERE status='active') TO 'active_users.csv' WITH (FORMAT csv, HEADER true)"
```

### 方法B：`COPY ... TO STDOUT` を標準出力にして、シェルでファイルに書く ★おすすめ

`COPY (SQL) TO STDOUT` は「画面（標準出力）に吐き出す」ので、シェルの `>` でファイルに保存できる。Aurora でも問題なく使える（サーバーにファイルを作らないため）。

```bash
psql -h <エンドポイント> -U app_user -d appdb \
  -c "COPY (SELECT * FROM users WHERE status='active') TO STDOUT WITH (FORMAT csv, HEADER true)" \
  > active_users.csv
```

日付入りのファイル名で残す（証跡・バックアップ向き）：

```bash
psql -d appdb \
  -c "COPY (SELECT * FROM orders) TO STDOUT WITH CSV HEADER" \
  > orders_$(date +%Y%m%d).csv
```

---

## 出力オプションいろいろ

```
-- 区切り文字をタブにする（TSV）
\copy users TO 'users.tsv' WITH (FORMAT csv, HEADER true, DELIMITER E'\t')

-- NULL を空文字ではなく "NULL" という文字で出す
\copy users TO 'users.csv' WITH (FORMAT csv, HEADER true, NULL 'NULL')

-- 全部の値をダブルクオートで囲む
\copy users TO 'users.csv' WITH (FORMAT csv, HEADER true, FORCE_QUOTE *)
```

### 日本語が Excel で文字化けする時（重要）

Windows の Excel は CSV を Shift-JIS だと思って開くため、UTF-8 の日本語が文字化けする。対策：

```bash
# 出力後に文字コードを Shift-JIS(CP932) に変換する
psql -d appdb -c "COPY (SELECT * FROM users) TO STDOUT WITH CSV HEADER" \
  | iconv -f UTF-8 -t CP932 > users_sjis.csv
```

または、UTF-8 の先頭に BOM を付けると Excel が UTF-8 と認識する：

```bash
# BOM付きUTF-8で出力
{ printf '\xEF\xBB\xBF'; psql -d appdb -c "COPY (SELECT * FROM users) TO STDOUT WITH CSV HEADER"; } > users_bom.csv
```

---

## 参考：画面表示の結果をそのままファイルに保存する（\o）

CSV ではなく「psql の表示（罫線つき）」をそのまま保存したい時は `\o`（output）を使う。

```
appdb=> \o result.txt        -- 以降の出力を result.txt に送る
appdb=> SELECT * FROM users;  -- 画面には出ず、ファイルに書かれる
appdb=> \o                    -- 出力先を画面に戻す
```

CSV っぽく（罫線なし・カンマ区切り）で保存したいなら：

```
appdb=> \pset format csv     -- 表示形式をCSVに
appdb=> \o users.csv
appdb=> SELECT * FROM users;
appdb=> \o
appdb=> \pset format aligned  -- 表示を元に戻す
```

---

## まとめ

| やりたいこと | コマンド |
|---|---|
| 接続中にテーブルを CSV 出力 | `\copy テーブル TO 'a.csv' WITH (FORMAT csv, HEADER true)` |
| 接続中に SELECT 結果を CSV 出力 | `\copy (SELECT ...) TO 'a.csv' WITH (FORMAT csv, HEADER true)` |
| シェルから一発で出力（自動化向き） | `psql -c "COPY (SELECT ...) TO STDOUT WITH CSV HEADER" > a.csv` |
| Excel の文字化け対策 | `... \| iconv -f UTF-8 -t CP932 > a.csv` |

**迷ったら**：接続中なら `\copy (SELECT ...) TO 'ファイル名' WITH (FORMAT csv, HEADER true)`、自動化するなら `COPY ... TO STDOUT > ファイル名`。
