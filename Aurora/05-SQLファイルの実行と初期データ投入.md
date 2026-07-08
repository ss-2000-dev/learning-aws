# 05. DDL(.sql) を効率よく実行する・初期データをミスなく投入する

## 用語：DDL / DML とは

| 略語 | 正式名 | 何をする | 例 |
|---|---|---|---|
| **DDL** | Data Definition Language | **構造**を定義する | `CREATE TABLE`, `ALTER TABLE`, `CREATE INDEX` |
| **DML** | Data Manipulation Language | **データ**を操作する | `INSERT`, `UPDATE`, `DELETE`, `SELECT` |

- `schema.sql`（テーブル定義など）＝ DDL
- `seed.sql`（初期データ）＝ DML（主に INSERT）

---

## SQL ファイルを実行する2つの方法

### 方法1：接続する前に、シェルから流す（`-f`）★構築時のおすすめ

まだ psql に入っていない状態で、ターミナルから直接ファイルを実行する。

```bash
psql -h <エンドポイント> -U app_user -d appdb -f schema.sql
```

### 方法2：psql に入ってから流す（`\i`）

すでに接続済みなら、メタコマンド `\i`（include）で実行できる。

```
appdb=> \i schema.sql
appdb=> \i /path/to/seed.sql    -- 絶対パスでもOK
```

> 💡 `\ir` を使うと、**今実行中の SQL ファイルからの相対パス**で別ファイルを読める。ファイルを分割している時に便利。

---

## 商用で必須の安全オプション（これを付けないと事故る）

`-f` で流すときは、以下を**セットで付けるのを習慣にする**。

```bash
psql -h <エンドポイント> -U app_user -d appdb \
     -v ON_ERROR_STOP=1 \
     --single-transaction \
     -f schema.sql
```

| オプション | 意味 | なぜ必要か |
|---|---|---|
| `-v ON_ERROR_STOP=1` | エラーが出たら**即停止** | デフォルトは**エラーを無視して残りを実行し続ける**。途中で壊れたまま最後まで走ると悲惨 |
| `--single-transaction`（`-1`） | ファイル全体を**1つのトランザクション**にする | 途中で失敗したら**全部ロールバック**。中途半端な状態を残さない（All or Nothing） |

### この2つの合わせ技が最強な理由

```
ON_ERROR_STOP=1 だけ    → エラーで止まるが、そこまでの変更は残る（中途半端）
--single-transaction だけ → 全体を1トランザクションにするが、エラー無視だと最後にまとめて失敗
両方つける              → エラーで止まり、かつ最初から全部無かったことにできる ✅
```

> ⚠️ **例外**：`CREATE INDEX CONCURRENTLY`（[06参照](./06-インデックス.md)）は**トランザクションの中で実行できない**。これを含むファイルには `--single-transaction` を付けられないので注意。DDL 用ファイルとインデックス用ファイルは分けると扱いやすい。

---

## 実行の様子を見たい（ログ・エコー）

デフォルトでは `CREATE TABLE` などの結果しか出ず、何を実行中か分かりにくい。以下で「今どの SQL を実行しているか」を表示できる。

```bash
# -a : ファイルの全行をそのまま表示しながら実行（echo all）
# -e : 実際に実行した SQL を表示（echo queries）
psql -a -v ON_ERROR_STOP=1 -f schema.sql

# 実行ログをファイルに残す（あとで確認できる。商用作業の証跡にもなる）
psql -a -v ON_ERROR_STOP=1 -f schema.sql 2>&1 | tee apply_$(date +%Y%m%d_%H%M%S).log
```

`tee` を使うと、画面に表示しつつログファイルにも保存できる。**商用作業では実行ログを残しておくと後で追跡できて安心**。

---

## 初期データ（seed）をうまく・ミスなく投入する

### コツ1：投入前後で件数を確認する

「入れたつもりが入ってなかった」を防ぐ。

```bash
# 投入前の件数
psql -d appdb -c "SELECT count(*) FROM users;"

# 投入
psql -d appdb -v ON_ERROR_STOP=1 --single-transaction -f seed.sql

# 投入後の件数（増えているか確認）
psql -d appdb -c "SELECT count(*) FROM users;"
```

`-c` は「1つの SQL だけ実行してすぐ抜ける」オプション。件数チェックに便利。

### コツ2：何度流しても大丈夫な書き方（冪等性）

seed.sql を間違えて2回流すと、データが二重に入る事故が起きる。**同じデータなら重複させない**書き方にしておくと安全。

```sql
-- ① ON CONFLICT で「既にあれば何もしない」
INSERT INTO users (id, name) VALUES
  (1, '太郎'),
  (2, '花子')
ON CONFLICT (id) DO NOTHING;   -- id が既にあればスキップ

-- ② ON CONFLICT で「既にあれば更新する」（UPSERT）
INSERT INTO settings (key, value) VALUES
  ('theme', 'dark')
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- ③ 一度まっさらにしてから入れ直す（開発環境向け。本番では慎重に）
TRUNCATE TABLE users RESTART IDENTITY CASCADE;
INSERT INTO users ...;
```

> 💡 **冪等（べきとう）** ＝「何回実行しても結果が同じ」という性質。seed を冪等にしておくと、失敗して再実行する時に安心。

### コツ3：大量データは INSERT より COPY / \copy が速い

数万件以上を1行ずつ `INSERT` すると遅い。CSV から一括投入する **`\copy`** が圧倒的に速い。

```
-- CSVファイルからテーブルへ一括投入（クライアント側のファイルを読む）
appdb=> \copy users(id, name, email) FROM 'users.csv' WITH (FORMAT csv, HEADER true)
```

| コマンド | 実行場所 | Aurora での使い勝手 |
|---|---|---|
| `\copy`（メタコマンド） | **手元/踏み台のファイル**を読む | ✅ Aurora で普通に使える |
| `COPY`（SQL） | **DBサーバー上のファイル**を読む | ⚠️ Aurora ではサーバーのファイルに触れないので、S3連携拡張が必要 |

> 💡 **迷ったら `\copy`（バックスラッシュ付き）**。手元の CSV をそのまま読めるので初心者はこれでよい。

### コツ4：S3 の大きなファイルから直接投入する（Aurora 専用の便利機能）

Aurora PostgreSQL には、S3 のファイルを直接読み込む拡張がある。数百万件など巨大な初期データに有効。

```sql
-- 一度だけ拡張を有効化（rds_superuser 権限が必要）
CREATE EXTENSION IF NOT EXISTS aws_s3 CASCADE;

-- S3のCSVをテーブルに取り込む
SELECT aws_s3.table_import_from_s3(
  'users',                                   -- 取込先テーブル
  'id,name,email',                           -- カラム
  '(FORMAT csv, HEADER true)',               -- フォーマット
  aws_commons.create_s3_uri('my-bucket', 'seed/users.csv', 'ap-northeast-1')
);
```
（別途、Aurora に S3 読み取りの IAM ロールを紐付ける設定が必要）

---

## 実行順序に注意（依存関係）

テーブルは**参照される側から先に**作る。外部キーの順番を間違えるとエラーになる。

```
1. schema.sql       -- テーブル定義（親→子の順）
2. constraints.sql  -- 外部キーなどの制約（テーブルが全部揃ってから）
3. seed.sql         -- 初期データ（親テーブルのデータ→子テーブルのデータ）
4. index.sql        -- インデックス（CONCURRENTLY はここで単独実行）
```

ファイルを分けておくと、順番に流せて管理しやすい。1つのスクリプトにまとめる例：

```bash
#!/bin/bash
set -e   # どれか失敗したら以降を止める（シェル側の安全策）

PSQL="psql -h $HOST -U app_user -d appdb -v ON_ERROR_STOP=1"

$PSQL --single-transaction -f 1_schema.sql
$PSQL --single-transaction -f 2_constraints.sql
$PSQL --single-transaction -f 3_seed.sql
$PSQL -f 4_index.sql   # CONCURRENTLY があるので --single-transaction は付けない

echo "✅ 全部完了"
```

---

## まとめ：商用で SQL ファイルを流す時のテンプレート

```bash
psql -h <エンドポイント> -U app_user -d appdb \
     -v ON_ERROR_STOP=1 \
     --single-transaction \
     -a \
     -f schema.sql 2>&1 | tee apply.log
```
「**エラーで止める・全体を1トランザクション・ログを残す**」の3点セットを習慣に。
