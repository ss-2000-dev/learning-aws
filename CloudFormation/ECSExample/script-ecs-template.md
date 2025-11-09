初回作成

```
aws cloudformation create-stack \
--stack-name sample-ecs-cluster-stack \
--template-body file://ecs-template.yaml \
--capabilities CAPABILITY_NAMED_IAM
```

更新

```
aws cloudformation update-stack \
--stack-name sample-ecs-cluster-stack \
--template-body file://ecs-template.yaml \
--capabilities CAPABILITY_NAMED_IAM
```

検証

```
aws cloudformation validate-template --template-body file://ecs-template.yaml
```

イメージ作成

```
docker build -t express-server-for-cloudformation-test .
```

ECR リポジトリ作成

```
aws ecr create-repository --repository-name express-server-for-cloudformation-test
```

プッシュ

```
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin {account-id}.dkr.ecr.ap-northeast-1.amazonaws.com \
docker tag express-server-for-cloudformation-test:latest {account-id}.dkr.ecr.ap-northeast-1.amazonaws.com/express-server-for-cloudformation-test:latest \
docker push {account-id}.dkr.ecr.ap-northeast-1.amazonaws.com/express-server-for-cloudformation-test:latest
```

デプロイ

```
aws cloudformation deploy \
 --template-file ecs-template.yaml \
 --stack-name sample-ecs-cluster-stack \
 --capabilities CAPABILITY_NAMED_IAM \
 --parameter-overrides \
 VpcId={vpc-id} \
 SubnetId1={subnet1-id} \
 SubnetId2={subnet2-id} \
 SecurityGroupId={securitygroup-id} \
 ContainerImage={account-id}.dkr.ecr.ap-northeast-1.amazonaws.com/express-server-for-cloudformation-test:latest
```

削除（安全に削除するなら、ECS タスクを停止してから）

```
aws cloudformation delete-stack \
  --stack-name sample-ecs-cluster-stack
```

削除確認

```
aws cloudformation describe-stacks
```

ECR リポジトリも削除

```
aws ecr delete-repository \
  --repository-name express-server-for-cloudformation-test \
  --force
```
