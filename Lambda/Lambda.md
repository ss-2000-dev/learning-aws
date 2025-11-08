# Lambda

- 一応定義したメモリよりも多い量のメモリも割り当てくれる（オーバープロビジョニング）

# Operating Lambda: パフォーマンスの最適化 – Part 1

## Lambda 実行環境のライフサイクル

1. Download your code
2. Start new execution environment
3. Execute initialization code
4. Execute handler code

- 1,2: Cold start duration
- 3,4: Invocation duration
- 1,2 が「コールドスタート」と呼ばれる
- Lambda が関数の準備に要する時間は課金されないが、全体的な実行時間に対して遅延を及ぼす
- 実行が完了すると、実行環境はフリーズされる
- リソース管理とパフォーマンスを向上させるために、Lambda サービスは実行環境を不特定期間保持している
- この間、同じ関数に対する追加のリクエストが到着すると、サービスは環境を再利用するよう試みます。通常、この 2 番目のリクエストはより迅速に終了します。これは、実行環境がすでに存在し、コードをダウンロードして初期化コードを実行する必要がないためです。これは「ウォームスタート」と呼ばれる
- コールドスタートは通常、本番環境のワークロードよりも開発およびテスト中の関数で多くみられます。これは、一般的に開発やテスト中の関数が呼び出される頻度が、本番環境のそれよりも低いため
- Lambda 関数のコードを更新したり、関数の設定を変更した場合、次の呼び出しにおいてコールドスタートが発生する

## Provisioned Concurrency によるコールドスタートの削減

- 非同期呼び出しの場合、呼び出し側と Lambda サービスの間に内部キューが存在します。Lambda は必要に応じて自動的にスケールアップしつつ、このキューからのメッセージをできるだけ早く処理します。関数に Reserved Concurrency が指定されている場合、これは関数単位の同時実行数の上限として機能するため、関数が処理できるようになるまでメッセージは内部キューに保持される

### 参考

- [Operating Lambda: パフォーマンスの最適化 – Part 1](https://aws.amazon.com/jp/blogs/news/operating-lambda-performance-optimization-part-1/)

# Operating Lambda: パフォーマンスの最適化 – Part 2

- メモリの設定が Lambda のパフォーマンスに与える影響と、メモリの設定が関数で利用可能な計算能力とネットワーク I/O を制御する理由

# Operating Lambda: パフォーマンスの最適化 – Part 3

- 開発者がパフォーマンスに最も大きな影響を与えることができる Lambda ライフサイクルの部分
- インタラクティブワークロードと非同期ワークロードを比較し、Lambda 関数の代わりに直接サービス統合を使用できる場合
- ワークロードの実行コストの削減にも役立つコスト最適化のヒントをいくつか紹介

# [AWS Lambda 関数を使用するためのベストプラクティス](https://docs.aws.amazon.com/ja_jp/lambda/latest/dg/best-practices.html)

# AWS Lambda テスト

# [AWS Lambda の超基本的な Tips](https://qiita.com/shibadai/items/fd483ccd2ad8c8d89c1a)

# Lambda Function URL

- API Gateway, ALB を利用せずにエンドポイントを作成して Lambda を呼び出せる機能
- 関数 URL を作成
  - 認証タイプ:
    - AWS_IAM: 認証された IAM ユーザーとロールのみが、関数 URL にリクエストを行うことができる
    - None: Lambda は、関数 URL へのリクエストに対して IAM 認証を実行しない。関数に独自の認可ロジックを実装しない限り、URL エンドポイントはパブリックになる
      - 認証タイプの NONE を選択すると、Lambda によってリソースベースのポリシーが自動的に作成され、関数にアタッチされる（auth-type-none.json）
        - 呼び出しモード: BUFFERED (デフォルト), RESPINSE_STREAM, CORS の設定

# なぜ VPC Lambda はローカル環境から呼び出せるのか

- Lambda の実体がユーザーの VPC 内にある訳ではなく、実体は AWS 管理の VPC 内にあり、ENI がユーザーの VPC 内にあるという仕組みの
- AWS のドキュメントにも記載されていますが、Invoke API のエンドポイントは lambda.{リージョン}.api.aws なので、呼び出し元がここに到達できさえすれば VPC Lambda でも呼び出せる
- 先ほど作成した VPC Lambda のセキュリティグループのインバウンドルールに許可設定を入れなくても呼び出せたことから、インバウンドルールは評価されていなさそう
- 参考: [ローカル環境から VPC Lambda ってどうして呼び出せるんだっけ？](https://zenn.dev/simpleform_blog/articles/c5938aece1b037)

### 実験

VPC Lambda の実験、関数 URL で実践

| サブネット | セキュリティグループインバウンドルール | セキュリティグループアウトバウンドルール | 結果                  |
| ---------- | -------------------------------------- | ---------------------------------------- | --------------------- |
| パブリック | HTTPS のみ許可                         | HTTPS のみ許可                           | Internal Server Error |
