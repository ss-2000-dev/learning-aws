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

```sh
docker build -t ecs-test .
```

```sh
docker build --platform linux/amd64 -t ecs-test .
```

プッシュ
```sh
ACCOUNT_ID="{ACCOUNT_ID}"
```

```sh
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
```

```sh
docker tag ecs-test:latest ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/ecs-test:latest  \
```

```sh
docker push ${ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/ecs-test:latest
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
 ContainerImage={account-id}.dkr.ecr.ap-northeast-1.amazonaws.com/ecs-test:latest
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
  --repository-name ecs-test \
  --force
```

# 2026-02-20 
`http://{PublicIP}:3000`でアクセスできるようになった