# ECS ログ

## やること
- FluentBitの設定ファイルの作成
- タスクロールの権限追加（S3への書き込み）
- アプリケーションのログ出力設定

## AWS 公式 Doc 
- [Amazon ECR Public Gallery](https://gallery.ecr.aws/)
- [Amazon ECS ログを AWS サービスまたは AWS Partner に送信する](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/using_firelens.html)
- [FirelensConfiguration](http://docs.aws.amazon.com/ja_jp/AmazonECS/latest/APIReference/API_FirelensConfiguration.html)
- [Amazon ECS タスク定義の例: FireLens にログをルーティングする](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/firelens-taskdef.html)

## 実現したいことに近い記事
- [AWS FireLensでECSコンテナのログをS3とCloudWatch logsに出力する](https://tech.nri-net.com/entry/aws_firelens_output_ecs_logs_to_s3_cloudwatch)
- [FireLensを使用してECS FargateでホストしているアプリケーションのログをS3とCloudWatch Logsロググループに出力してみた](https://dev.classmethod.jp/articles/firelens-ecs-fargate-s3-cloudwatch-logs/)

## ECR
- [aws-observability/aws-for-fluent-bit](https://gallery.ecr.aws/aws-observability/aws-for-fluent-bit)

## メモ
- マルチ設定機能をご利用になる場合は、initプロセスを含むinitタグ付きaws-for-fluent-bit:init-latestのFluent Bitイメージを選ぶ必要がある
- AWS Fargate でホストされるタスクは、file設定ファイルタイプのみをサポートする -> おそらくなおっていないはずなんだよな 
- FluentBitの設定ファイルがおかしい、権限不足

```yaml
          LogConfiguration:
            LogDriver: awsfirelens
            Options:
              Name: fluent-bit-test # エラー回避用
```
