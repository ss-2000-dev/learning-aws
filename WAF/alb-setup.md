# WAF + ALB 設定手順

## 概要

ALB（Application Load Balancer）に WAF を適用することで、アプリケーション層でのリクエスト検査を行う。
CloudFront を使わない構成や、CloudFront の後段の ALB にも多重防御として WAF を適用したい場合に使用する。

---

## ALB WAF の特徴

| 項目 | 内容 |
|---|---|
| **Scope** | `REGIONAL`（ALB と同じリージョン） |
| **対象** | 同一リージョンの ALB |
| **評価タイミング** | ALB がリクエストを受け取った後、ターゲット（EC2 / ECS 等）に転送する前 |

---

## アーキテクチャ

```
クライアント
    │
    ▼
[Route 53]
    │
    ▼
[ALB]  ←── WAF が評価（REGIONAL スコープの Web ACL を参照）
    │  悪意あるリクエスト → 403 BLOCK
    │  正常なリクエスト ↓
    ▼
[Target Group: EC2 / ECS / Lambda など]
```

### CloudFront + ALB の多重防御構成

```
クライアント
    │
    ▼
[CloudFront]  ←── CloudFront WAF（CLOUDFRONT スコープ、us-east-1）
    │  エッジで一次フィルタリング
    ▼
[ALB]  ←── ALB WAF（REGIONAL スコープ）
    │  バックエンド直接アクセス対策・多重防御
    ▼
[Target Group]
```

> **多重防御の考え方:** CloudFront をバイパスして ALB に直接アクセスされるリスクがあるため、重要なシステムでは ALB にも WAF を適用することを推奨。

---

## 設定手順（マネジメントコンソール）

### 1. WAF Web ACL の作成

1. AWS マネジメントコンソールを開き、**ALB と同じリージョンを選択**
2. `WAF & Shield` サービスを開く
3. 「Web ACLs」→「Create web ACL」をクリック
4. 設定内容：
   - **Name:** 任意の名前（例：`my-alb-waf`）
   - **Resource type:** `Regional resources`（ALB の場合）
   - **Region:** ALB と同じリージョン（例：`Asia Pacific (Tokyo)`）
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

### 3. ALB へのアタッチ

**方法 A: WAF 作成時に紐付ける**
- Web ACL 作成の「Associate AWS resources」ステップで、対象の ALB を選択する

**方法 B: WAF コンソールから紐付ける**
1. 作成した Web ACL を開く
2. 「Associated AWS resources」タブ
3. 「Add AWS resources」→ ALB を選択

**方法 C: ALB コンソールから紐付ける**
1. EC2 → ロードバランサー → 対象の ALB を選択
2. 「Integrations」タブ → 「AWS WAF」
3. 「Enable」→ 作成した Web ACL を選択

### 4. 動作確認

```bash
# ALB のエンドポイントに正常リクエスト（200 が返ることを確認）
curl -I http://your-alb-dns-name.ap-northeast-1.elb.amazonaws.com/

# SQL インジェクションのテスト（403 が返ることを確認）
curl -I "http://your-alb-dns-name.ap-northeast-1.elb.amazonaws.com/?id=1'+OR+'1'='1"

# XSS のテスト（403 が返ることを確認）
curl -I "http://your-alb-dns-name.ap-northeast-1.elb.amazonaws.com/?q=<script>alert(1)</script>"
```

---

## 設定手順（CloudFormation）

### テンプレートファイル

[templates/waf-alb.yaml](./templates/waf-alb.yaml) を使用する。

### デプロイ手順

```bash
# WAF スタックを ALB と同じリージョンにデプロイ
aws cloudformation deploy \
  --template-file templates/waf-alb.yaml \
  --stack-name my-alb-waf \
  --region ap-northeast-1 \
  --parameter-overrides \
    Environment=production \
    AlbArn=arn:aws:elasticloadbalancing:ap-northeast-1:123456789012:loadbalancer/app/my-alb/abc123 \
    RateLimitThreshold=5000

# デプロイ結果の確認
aws cloudformation describe-stacks \
  --stack-name my-alb-waf \
  --region ap-northeast-1 \
  --query "Stacks[0].Outputs"
```

> **Parameters の `AlbArn` について:**
> テンプレートの `AlbArn` パラメータに ALB の ARN を渡すことで、自動的に WAF が ALB にアタッチされる。
> ALB ARN は `aws elbv2 describe-load-balancers` コマンドで確認できる。

---

## X-Forwarded-For の扱い（ALB + CloudFront 構成）

CloudFront → ALB 構成では、ALB の WAF が受け取る送信元 IP は CloudFront のエッジノードの IP になる。
実際のクライアント IP は `X-Forwarded-For` ヘッダーに格納されている。

ALB の WAF で実クライアント IP を評価するには、IP セットルールの `HeaderName` に `X-Forwarded-For` を指定する：

```yaml
Statement:
  IPSetReferenceStatement:
    Arn: !GetAtt BlockIpSet.Arn
    IPSetForwardedIPConfig:
      HeaderName: X-Forwarded-For
      FallbackBehavior: MATCH   # XFF ヘッダーがない場合はブロック扱い
      Position: FIRST           # XFF の最初の IP（本来のクライアント IP）を評価
```

> **Position の選択:**
> - `FIRST`: XFF の先頭 IP（クライアントに最も近い IP）を使用
> - `LAST`: XFF の末尾 IP（直近のプロキシ IP）を使用
> - `ANY`: XFF 内のいずれかの IP がリストにあればマッチ

---

## ログの設定（ALB WAF）

```bash
# CloudWatch Logs グループを作成（WAF ログ用のグループ名は "aws-waf-logs-" で始める）
aws logs create-log-group \
  --log-group-name aws-waf-logs-alb \
  --region ap-northeast-1

# WAF ログを有効化
aws wafv2 put-logging-configuration \
  --logging-configuration '{
    "ResourceArn": "YOUR_WEB_ACL_ARN",
    "LogDestinationConfigs": [
      "arn:aws:logs:ap-northeast-1:123456789012:log-group:aws-waf-logs-alb"
    ]
  }' \
  --region ap-northeast-1
```

---

## ALB と CloudFront の WAF 比較

| 項目 | CloudFront WAF | ALB WAF |
|---|---|---|
| Scope | CLOUDFRONT | REGIONAL |
| デプロイリージョン | us-east-1 固定 | ALB と同じリージョン |
| 評価タイミング | エッジノード（世界各地） | ALB のあるリージョン |
| 主な用途 | 広域的な攻撃のエッジ遮断 | バックエンド保護・多重防御 |
| クライアント IP | 直接参照可能 | XFF ヘッダー参照が必要（CF 経由時） |

---

## トラブルシューティング

| 症状 | 原因 | 対処 |
|---|---|---|
| WAF を ALB にアタッチできない | Scope が CLOUDFRONT になっている | REGIONAL Scope で作り直す |
| WAF が違うリージョンにある | ALB と別リージョンにデプロイした | 同じリージョンで作り直す |
| IP ブロックが機能しない | CF 経由で XFF に IP が入っている | IPSetForwardedIPConfig を設定する |
| 正常なリクエストがブロックされる | マネージドルールの誤検知 | 該当ルールを Count に変更して調査 |
