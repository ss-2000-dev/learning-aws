## 全体像

```
CodeCommit
   ↓
EventBridge (変更検知)
   ↓
CodePipeline (CI/CDの管理)
   ↓
CodeBuild (ビルド & Docker push)
   ↓
ECR
   ↓
ECS Fargate (実行環境の更新)
```

## ステップ 0：前提と事前準備

- デプロイ方式：今回は標準デプロイで行う  
  ECS Rolling Update（Blue/Green はまたの機会に...）
- イメージタグ戦略：`latest` + `commitSha`（実務ではこれが安定）
- ECS クラスター、サービス、タスク定義、ECR、CodeCommit を作成して CI/CD 学習前の土台を作る（以下はメモ）
  - 起動タイプ：Fargate
  - Deployment controller：**ECS**
  - タスク定義のコンテナ名：
    - **buildspec の `name` と完全一致**

```json
[
  {
    "name": "app",
    "imageUri": "xxx"
  }
]
```

## ステップ 2：CodeBuild（Docker build & push）

### 役割

- CodeCommit のソースを受け取る
- Docker build
- ECR に push
- `imagedefinitions.json` を生成（← 超重要）

### CloudFormation で作るもの

- **IAM Role（ECR push 権限）**
- CodeBuild

### 注意点

- **ECS 更新には `imagedefinitions.json`が必要**
- VPC 内実行や IAM の最小権限の法則はいったんおいておく

---

## ステップ 3：CodePipeline（CI/CD の中枢）

### 構成ステージ

1. **Source**：CodeCommit
2. **Build**：CodeBuild
3. **Deploy**：ECS

### CloudFormation で作るもの

- CodePipeline
- IAM Role（CodePipeline 自身のロール）
- Artifact 用 S3

#### Deploy ステージ（ECS）

```yaml
- Name: Deploy
  Actions:
    - Name: DeployToECS
      ActionTypeId:
        Category: Deploy
        Owner: AWS
        Provider: ECS
        Version: "1"
      Configuration:
        ClusterName: my-cluster
        ServiceName: my-service
        FileName: imagedefinitions.json
      InputArtifacts:
        - Name: BuildArtifact
```

### 注意点

- CodePipeline では**ここでタスク定義は触らない**  
  → CodePipeline が **自動で新 Revision を作成** します。

---

## ステップ 4：EventBridge（main 変更検知）

### なぜ必要か？

- CodePipeline は「自動トリガー」が弱い
- EventBridge で **main ブランチ限定** にできる

### CloudFormation で作るもの

- EventBridge
- IAM Role（CodePipeline 実行ロール）

### Event ルール例

```yaml
CodeCommitEventRule:
  Type: AWS::Events::Rule
  Properties:
    EventPattern:
      source:
        - aws.codecommit
      detail-type:
        - CodeCommit Repository State Change
      detail:
        event:
          - referenceUpdated
        referenceType:
          - branch
        referenceName:
          - main
    Targets:
      - Arn: !Sub arn:aws:codepipeline:${AWS::Region}:${AWS::AccountId}:my-pipeline
        RoleArn: !GetAtt EventBridgeRole.Arn
        Id: CodePipelineTarget
```

---

## さらにやるなら...

1. **環境別（dev/stg/prod）**

   - Parameter + Condition で切り替え

2. **タグ戦略の見直し**

   - `commitSha` + `env`

3. **失敗通知**

   - SNS + CodePipeline 失敗イベント

4. **ファイル分割（スタック分割）**
   - Export/Import をうまく利用する必要がでてくる

ex

```
iam.yaml
ecr.yaml
codebuild.yaml
codepipeline.yaml
eventbridge.yaml
```

5. **Blue/Green（CodeDeploy）**

   - 無停止 & 切り戻し可能

6. **IAM の最小権限化**
