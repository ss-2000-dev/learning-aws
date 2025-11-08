# Athena 概要

- Amazon Athena は、標準的な SQL を使用して Amazon Simple Storage Service (Amazon S3) 内のデータを直接分析することを容易にするインタラクティブなクエリサービス
- 実行したクエリにのみ課金される
- Amazon S3 に保存された非構造化データ、半構造化データ、および構造化データの分析に役立つ
  - CSV 形式、JSON 形式、列データ形式 (Apache Parquet や Apache ORC など) に対応している

# [Amazon Athena Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/9981f1a1-abdc-49b5-8387-cb01d238bb78/en-US)

- Athena の基礎のみ実施
- ラボを試すために必要な IAM ユーザー、Athena ワークグループ、Athena 名前付きクエリは CloudFormaion テンプレートで定義（スタック名:athena-workshop-2025-10-19）
  ― ファイル形式が「parquet」（拡張子が parquet？）
- https://catalog.us-east-1.prod.workshops.aws/workshops/9981f1a1-abdc-49b5-8387-cb01d238bb78/en-US/30-basics/301-create-tables ここまで

# チュートリアル → 　あんまり参考にならない

### 参考

- [はじめに](https://docs.aws.amazon.com/ja_jp/athena/latest/ug/getting-started.html)

# `aws athena help`コマンド実行結果

```
athena
^^^^^^


Description
***********

Amazon Athena is an interactive query service that lets you use
standard SQL to analyze data directly in Amazon S3. You can point
Athena at your data in Amazon S3 and run ad-hoc queries and get
results in seconds. Athena is serverless, so there is no
infrastructure to set up or manage. You pay only for the queries you
run. Athena scales automatically executing queries in parallel o
results are fast, even with large datasets and complex queries. For
more information, see What is Amazon Athena in the *Amazon Athena User
Guide* .

If you connect to Athena using the JDBC driver, use version 1.1.0 of
the driver or later with the Amazon Athena API. Earlier version
drivers do not support the API. For more information and to download
the driver, see Accessing Amazon Athena with JDBC .


Available Commands
******************

* batch-get-named-query

* batch-get-prepared-statement

* batch-get-query-execution

* cancel-capacity-reservation

* create-capacity-reservation

* create-data-catalog

* create-named-query

* create-notebook

* create-prepared-statement

* create-presigned-notebook-url

* create-work-group

* delete-capacity-reservation

* delete-data-catalog

* delete-named-query

* delete-notebook

* delete-prepared-statement

* delete-work-group

* export-notebook

* get-calculation-execution

* get-calculation-execution-code

* get-calculation-execution-status

* get-capacity-assignment-configuration

* get-capacity-reservation

* get-data-catalog

* get-database

* get-named-query

* get-notebook-metadata

* get-prepared-statement

* get-query-execution

* get-query-results

* get-query-runtime-statistics

* get-session

* get-session-status

* get-table-metadata

* get-work-group

* help

* import-notebook

* list-application-dpu-sizes

* list-calculation-executions

* list-capacity-reservations

* list-data-catalogs

* list-databases

* list-engine-versions

* list-executors

* list-named-queries

* list-notebook-metadata

* list-notebook-sessions

* list-prepared-statements

* list-query-executions

* list-sessions

* list-table-metadata

* list-tags-for-resource

* list-work-groups

* put-capacity-assignment-configuration

* start-calculation-execution

* start-query-execution

* start-session

* stop-calculation-execution

* stop-query-execution

* tag-resource

* terminate-session

* untag-resource

* update-capacity-reservation

* update-data-catalog

* update-named-query

* update-notebook

* update-notebook-metadata

* update-prepared-statement

* update-work-group

```
