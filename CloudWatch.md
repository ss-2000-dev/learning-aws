# CloudWatch Logs Insight

- ログイベントのフィールドセット、ログイベントで実行された数学的集計やその他の操作結果を返す
- CloudWatch Logs Insight は３つのクエリをサポートしている
  - クエリ,PPL, SQL

## CloudWatch Logs Insight クエリ構文学習

- クエリを実行するのにも費用がかかる
- フィールド名に英数字以外の文字が含まれている場合は、フィールド名の前後にバッククォート文字 (\`) を挿入する必要がある (例: \`error-code\`="102")。
  - 英数字以外の文字を含むフィールド名にはバッククォート文字を使用する必要がありますが、値には必要ない、値は常に引用符（"）で囲む
- 集計関数は、stats コマンドや他の関数の引数として使用できる
- ログフィールドごとにグループ化された視覚化を生成するクエリを実行手順
  - クエリを実行（ex3）→ [視覚化]タブを選択 → [線]の横にある矢印を選択し、[棒]を選択します。
- bin()関数を使用して返された結果を期間ごとにグループ化するクエリを実行すると、結果を折れ線グラフ、積み上げ面グラフ、円グラフ、または棒グラフで表示できる。これによりログイベントの傾向を時間経過とともにより効率的に視覚化（ex4）
- stats を使用して、棒グラフ、折れ線グラフ、積み上げ面グラフなどのログデータの視覚化を作成できる
- 1 つのクエリで最大 2 つの stats コマンドを使用できる
- 参考
  - [クエリ構文](https://docs.aws.amazon.com/en_us/AmazonCloudWatch/latest/logs/CWL_QuerySyntax.html)
  - [チュートリアル](https://docs.aws.amazon.com/en_us/AmazonCloudWatch/latest/logs/CWL_AnalyzeLogData_Tutorials.html)
  - [サンプルクエリ](https://docs.aws.amazon.com/en_us/AmazonCloudWatch/latest/logs/CWL_QuerySyntax-examples.html) → Lambda ログのクエリがある

### サンプルクエリ

ex1

```
fields @timestamp, @message, @logStream, @log
| sort @timestamp desc
| limit 50
| filter @message like "Start"
```

ex2

```
stats count(*) by @message
| limit 5
```

ex3

```
stats count(*) by @logStream
| limit 20
```

ex4. 30 秒（30 分）ごとに CloudWatch Logs によって受信されたロググループ内のログイベントの数を表示

```
stats count(*) by bin(30s)
stats count(*) by bin(30m)
```

ex5. 異なるフィールドに基づいて 3 つの値の視覚化を生成

```
stats avg(myfield1), min(myfield2), max(myfield3) by bin(5m)
```

ex6. Lambda のメモリ利用量を可視化したい（以下はエクスポートして Excel を利用すれば可視化できるが...）

```
fields @timestamp, @maxMemoryUsed as MaxMemoryUsed_MB, @memorySize
| filter @type = "REPORT"
| sort @timestamp asc
| display @timestamp, MaxMemoryUsed_MB
```

これならできる

```
stats max(@maxMemoryUsed), max(@memorySize) by bin(30m)
```

ex7.時間ごとの発生回数をテーブル表示する

```
fields @timestamp, @message
| sort @timestamp desc
| filter @message like /takashi.ishikawa/
| stats count(*) as exceptionCount by bin(5m)
| sort exceptionCount desc
```

ex8.

```
fields @timestamp, @message, @logStream, @log
| filter @message like "ERROR"
| filter @message like "1821207"
| filter @timestamp > 1687173840000 and @timestamp <= 1687173900000
| sort @timestamp asc
| limit 20
| display @timestamp, @message
```

# CloudWatch ダッシュボード

- カスタムダッシュボードには費用がかかる...（存在している時間だけ金がかかる..）
- 1 ヵ月間のカスタムダッシュボードが存在する時間数に基づいて按分される
- USD 3.00/ダッシュボード/月
