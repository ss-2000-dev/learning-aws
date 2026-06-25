# WAF + CloudFront 設定手順

## 概要

CloudFront に WAF を適用することで、CDN レイヤーで攻撃トラフィックをブロックする。
オリジン（ALB / EC2 / S3 等）にリクエストが到達する前にブロックできるため、オリジンへの負荷軽減にも効果的。

---

## CloudFront WAF の制約（重要）

| 項目 | 内容 |
|---|---|
| **Scope** | `CLOUDFRONT` 固定（`REGIONAL` は使えない） |
| **デプロイリージョン** | **必ず `us-east-1`（バージニア北部）にデプロイする** |
| **理由** | CloudFront はグローバルサービスであり、WAF の評価を us-east-1 で一元管理している |

> **CloudFormation でのデプロイ方法：**
> - CloudFront 本体と WAF を別スタックに分けて、WAF スタックは `us-east-1` のリージョンに対してデプロイする。
> - または CloudFront と WAF を同じテンプレートに書き、`--region us-east-1` でデプロイする。

---

## アーキテクチャ

```
クライアント
    │
    ▼
[CloudFront]  ←── WAF が評価（us-east-1 の Web ACL を参照）
    │  悪意あるリクエスト → 403 BLOCK
    │  正常なリクエスト ↓
    ▼
[Origin: ALB / S3 / EC2 など]
```

---

## 設定手順（マネジメントコンソール）

### 1. WAF Web ACL の作成（us-east-1 で実施）

1. AWS マネジメントコンソールにログインし、**リージョンを us-east-1（バージニア北部）に変更**
2. `WAF & Shield` サービスを開く
3. 「Web ACLs」→「Create web ACL」をクリック
4. 設定内容：
   - **Name:** 任意の名前（例：`my-cloudfront-waf`）
   - **Resource type:** `Amazon CloudFront distributions`
   - **Region:** `Global (CloudFront)`
5. ルールを追加する（後述）
6. 「Default action」を `Allow` に設定
7. 「Create web ACL」で作成

### 2. ルールの追加

「Add rules」から以下のマネージドルールグループを追加する：

| 追加するルールグループ | 設定 |
|---|---|
| `AWS-AWSManagedRulesCommonRuleSet` | Override action: None |
| `AWS-AWSManagedRulesKnownBadInputsRuleSet` | Override action: None |
| `AWS-AWSManagedRulesSQLiRuleSet` | Override action: None |
| `AWS-AWSManagedRulesLinuxRuleSet` | Override action: None |
| `AWS-AWSManagedRulesAmazonIpReputationList` | Override action: None |
| `AWS-AWSManagedRulesAnonymousIpList` | Override action: None |

カスタムルールとして追加：
- IP ブロックリスト（悪意ある IP）
- IP 許可リスト（管理者 IP）
- レートリミット（5,000 req / 5分）

### 3. CloudFront ディストリビューションへのアタッチ

**方法 A: WAF 作成時に紐付ける**
- Web ACL 作成の「Associate AWS resources」ステップで、対象の CloudFront ディストリビューションを選択する

**方法 B: CloudFront の設定から紐付ける**
1. CloudFront コンソールを開く
2. 対象のディストリビューションを選択
3. 「Security」タブ → 「Web Application Firewall (WAF)」
4. 「Enable security protections」を有効化し、作成した Web ACL を選択
5. 「Save changes」

### 4. 動作確認

```bash
# 正常リクエスト（200 が返ることを確認）
curl -I https://your-cloudfront-domain.cloudfront.net/

# SQL インジェクションのテスト（403 が返ることを確認）
curl -I "https://your-cloudfront-domain.cloudfront.net/?id=1'+OR+'1'='1"

# ブロックされた IP からのアクセス確認はコンソールの「Sampled requests」で確認
```

---

## 設定手順（CloudFormation）

### テンプレートファイル

[templates/waf-cloudfront.yaml](./templates/waf-cloudfront.yaml) を使用する。

### デプロイ手順

```bash
# WAF スタックを us-east-1 にデプロイ（CloudFront WAF は必ず us-east-1）
aws cloudformation deploy \
  --template-file templates/waf-cloudfront.yaml \
  --stack-name my-cloudfront-waf \
  --region us-east-1 \
  --parameter-overrides \
    Environment=production \
    RateLimitThreshold=5000

# デプロイ完了後、出力から Web ACL ARN を取得
aws cloudformation describe-stacks \
  --stack-name my-cloudfront-waf \
  --region us-east-1 \
  --query "Stacks[0].Outputs[?OutputKey=='WebACLArn'].OutputValue" \
  --output text
```

### CloudFront ディストリビューションへのアタッチ（CLI）

```bash
# CloudFront の現在の設定を取得
aws cloudfront get-distribution-config --id YOUR_DISTRIBUTION_ID > dist-config.json

# ETag を取得（更新時に必要）
ETAG=$(aws cloudfront get-distribution-config \
  --id YOUR_DISTRIBUTION_ID \
  --query "ETag" --output text)

# WebACLId を設定した上で更新
# dist-config.json 内の "WebACLId" フィールドに WAF ARN をセットして実行
aws cloudfront update-distribution \
  --id YOUR_DISTRIBUTION_ID \
  --if-match $ETAG \
  --distribution-config file://dist-config-updated.json
```

---

## ログの設定（CloudFront WAF）

WAF のリクエストログを S3 に保存する設定：

```bash
# S3 バケットを us-east-1 に作成
aws s3 mb s3://my-waf-logs-bucket --region us-east-1

# WAF ログを有効化（バケット名は "aws-waf-logs-" で始める必要がある）
aws wafv2 put-logging-configuration \
  --logging-configuration '{
    "ResourceArn": "YOUR_WEB_ACL_ARN",
    "LogDestinationConfigs": ["arn:aws:s3:::aws-waf-logs-my-bucket"]
  }' \
  --region us-east-1
```

> **注意:** WAF のログ用 S3 バケット名は必ず `aws-waf-logs-` で始まる必要がある。

---

## トラブルシューティング

| 症状 | 原因 | 対処 |
|---|---|---|
| WAF を作成できない | リージョンが us-east-1 以外 | us-east-1 に切り替えてから作成 |
| CloudFront に WAF を紐付けられない | Scope が REGIONAL になっている | CLOUDFRONT Scope で作り直す |
| 正常なリクエストがブロックされる | マネージドルールの誤検知 | 該当ルールを Count に変更して調査 |
| WAF が機能していない | CloudFront にアタッチされていない | CloudFront の Security タブを確認 |
