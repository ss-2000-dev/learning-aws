# ECS ログ

## 実現したいことに近い記事
- [AWS FireLensでECSコンテナのログをS3とCloudWatch logsに出力する](https://tech.nri-net.com/entry/aws_firelens_output_ecs_logs_to_s3_cloudwatch)
- [FireLensを使用してECS FargateでホストしているアプリケーションのログをS3とCloudWatch Logsロググループに出力してみた](https://dev.classmethod.jp/articles/firelens-ecs-fargate-s3-cloudwatch-logs/)

## やること
- FluentBitの設定ファイルの作成
- タスクロールの権限追加（S3への書き込み）
- アプリケーションのログ出力設定
