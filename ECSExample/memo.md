### 作成手順

1. クラスターの定義
2. タスク定義を定義
3. 自作イメージの作成（Node Express）& タスク定義の更新
4. サービスの定義

#### メモ

- 失敗ログは CloudTrail から確認可能

#### Recommended Next Step

- ALB（ロードバランサ）を追加して外部アクセス可能に
- ECR の管理を追加
- VPC, Subnet, SecurityGroup の指定方法を変更
- CI/CD を組む

### 参考

- [Amazon ECS resource type reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/AWS_ECS.html)
- [AWS CLI コマンドを使用した AWS CloudFormation の Amazon ECS リソースの作成](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/ecs-cloudformation-cli.html#ecs-cloudformation-cli-verify)
- [既存のリソースからスタックを作成する](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/resource-import-new-stack.html)
- [Examples of CloudFormation stack operation commands for the AWS CLI and PowerShell](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/service_code_examples.html)

#### 成功ログ（aws cloudformation deploy）

```
Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - sample-ecs-cluster-stack
```
