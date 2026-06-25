# AWS WAF (Web Application Firewall) 概要ドキュメント

## WAF とは

AWS WAF（Web Application Firewall）は、HTTP/HTTPS リクエストを検査し、ルールに基づいてトラフィックを**許可・ブロック・カウント**するマネージドサービス。

主な役割：
- SQL インジェクション、XSS、コマンドインジェクションなどの Web 攻撃を防ぐ
- DDoS・ブルートフォース攻撃をレートリミットで緩和する
- 悪意ある IP やボットトラフィックをブロックする
- 特定の IP・国・リクエストパターンに基づくアクセス制御を行う

---

## WAF の保護対象リソース

| リソース | Scope |
|---|---|
| Amazon CloudFront | `CLOUDFRONT`（**us-east-1 にデプロイ必須**） |
| Application Load Balancer（ALB） | `REGIONAL` |
| Amazon API Gateway (REST) | `REGIONAL` |
| AWS AppSync | `REGIONAL` |
| Amazon Cognito ユーザープール | `REGIONAL` |

---

## WAF の構成要素

### Web ACL（Web Access Control List）

WAF の最上位の管理単位。複数のルールをまとめたグループ。

- Web ACL 単位でリソース（CloudFront / ALB など）にアタッチする
- デフォルトアクション（`ALLOW` / `BLOCK`）を設定できる
  - `ALLOW`：ルールに一致しないリクエストをすべて許可（通常はこちらを使用）
  - `BLOCK`：ルールに一致しないリクエストをすべてブロック（完全ホワイトリスト運用の場合）

### ルール（Rule）

リクエストを評価する条件（Statement）とアクション（Action）のセット。

```
Rule
├── Statement（条件）
│   ├── IPSetReferenceStatement  → IP アドレスの照合
│   ├── ByteMatchStatement       → リクエスト内の文字列照合
│   ├── SqliMatchStatement       → SQL インジェクションの検出
│   ├── XssMatchStatement        → XSS の検出
│   ├── RateBasedStatement       → レートリミット
│   ├── GeoMatchStatement        → 国ベースの制御
│   └── ManagedRuleGroupStatement → AWS マネージドルールグループ
└── Action（アクション）
    ├── Allow  → 許可
    ├── Block  → ブロック（デフォルト: 403 を返す）
    ├── Count  → カウントのみ（実際のブロックはしない）
    ├── Captcha → CAPTCHA チャレンジを表示
    └── Challenge → ブラウザチャレンジを表示（ボット対策）
```

### 優先度（Priority）

- ルールは Priority の昇順（小さい数字が先）で評価される
- 最初に一致したルールのアクションが適用される（後続ルールは評価されない）

---

## AWS マネージドルールグループ

AWS が管理する既製のルールセット。自分でルールを書かずに高品質な防御を追加できる。

### 主なマネージドルールグループ一覧

| ルールグループ名 | 内容 | 課金 |
|---|---|---|
| `AWSManagedRulesCommonRuleSet` | OWASP Top 10 全般対策（XSS, LFI, RFI 等） | 無料 |
| `AWSManagedRulesAdminProtectionRuleSet` | 管理画面（/admin 等）への不正アクセス対策 | 無料 |
| `AWSManagedRulesKnownBadInputsRuleSet` | 既知の悪意あるリクエストパターンをブロック | 無料 |
| `AWSManagedRulesSQLiRuleSet` | SQL インジェクション対策 | 無料 |
| `AWSManagedRulesLinuxRuleSet` | Linux OS コマンドインジェクション対策 | 無料 |
| `AWSManagedRulesUnixRuleSet` | UNIX 系コマンドインジェクション対策 | 無料 |
| `AWSManagedRulesWindowsRuleSet` | Windows コマンドインジェクション対策 | 無料 |
| `AWSManagedRulesPHPRuleSet` | PHP アプリケーション向け攻撃対策 | 無料 |
| `AWSManagedRulesWordPressRuleSet` | WordPress 向け攻撃対策 | 無料 |
| `AWSManagedRulesAmazonIpReputationList` | AWS が管理する悪意ある IP のブロック | 無料 |
| `AWSManagedRulesAnonymousIpList` | Tor / VPN / プロキシ経由 IP のブロック | 無料 |
| `AWSManagedRulesBotControlRuleSet` | ボットトラフィックの検出・制御 | **有料** |
| `AWSManagedRulesATPRuleSet` | アカウント乗っ取り対策 | **有料** |
| `AWSManagedRulesACFPRuleSet` | 不正アカウント作成対策 | **有料** |

### OverrideAction について

マネージドルールグループ全体のアクションを上書きできる。

```yaml
OverrideAction:
  None: {}   # マネージドルールのアクション（BLOCK 等）をそのまま使う（通常はこれ）
  Count: {}  # すべてのルールを COUNT に上書き（動作確認・テスト時に使う）
```

> **運用 Tip:** 新しいマネージドルールを追加するときは、まず `Count` で様子を見て誤検知がないか確認してから `None` に変更するのが安全。

---

## WAF のログ設定

WAF はリクエストの検査結果をログに記録できる。

### ログの送信先

- **Amazon Kinesis Data Firehose** → S3 / Redshift / OpenSearch に流す
- **Amazon S3**（直接）
- **Amazon CloudWatch Logs**

### ログの使い道

- どのルールが何件マッチしたか確認
- 誤検知（本来許可すべきリクエストがブロックされていないか）の確認
- セキュリティインシデント時の調査

### CloudWatch メトリクス

Web ACL と各ルールに対してメトリクス名を設定することで、CloudWatch でグラフ化・アラート設定が可能。

---

## WAF の料金（概算）

| 項目 | 料金 |
|---|---|
| Web ACL | $5.00 / 月 |
| ルール（カスタムルール） | $1.00 / ルール / 月 |
| リクエスト処理 | $0.60 / 100万リクエスト |
| マネージドルールグループ（有料） | ルールグループごとに異なる（BotControl は追加で $10 / 月〜） |

> **注意:** CloudFront の WAF は us-east-1 で課金される。

---

## WAF 設計のベストプラクティス

1. **新規ルールはまず Count で運用** — 誤検知を確認してから Block に切り替える
2. **ログを必ず有効化する** — インシデント対応・チューニングに不可欠
3. **CloudWatch アラームを設定する** — ブロック数の急増を検知できる
4. **IP 許可リストを管理者 IP に絞る** — VPN や踏み台サーバーの IP を登録する
5. **マネージドルールの WCU（Web ACL Capacity Unit）に注意** — 1つの Web ACL は最大 5,000 WCU まで

---

## CIDR（サイダー）表記について

IP アドレスの範囲を表す記法。WAF の IP セットに登録する IP は CIDR 形式で記載する。

IP アドレスは 32 ビットで構成されており、`/` の後の数字は**ネットワーク部のビット数**（固定するビット数）を表す。

```
192 . 0  . 2  . 100
11000000.00000000.00000010.01100100
└──────────────────────────────────┘
              全部で 32bit
```

| 表記 | ネットワーク部 | ホスト部 | 対象 IP 数 | 用途例 |
|---|---|---|---|---|
| `192.0.2.100/32` | 32bit（全部固定） | 0bit | **1 個** | 特定の1台だけ指定 |
| `192.0.2.0/28` | 28bit 固定 | 4bit 可変 | **16 個**（.0〜.15） | 小さいサブネット |
| `192.0.2.0/24` | 24bit 固定 | 8bit 可変 | **256 個**（.0〜.255） | サブネット単位 |
| `192.0.0.0/16` | 16bit 固定 | 16bit 可変 | **65,536 個** | 大きなレンジ |

### 図解

```
/32（1個だけ）
  192 . 0  . 2  . 100
  ←── 全 32bit 固定 ──→   → 192.0.2.100 の 1 個だけ

/24（256個）
  192 . 0  . 2  . ???
  ←── 24bit 固定 ──→ ↑8bit 可変   → 192.0.2.0〜192.0.2.255 の 256 個
```

### WAF での使い方

```yaml
Addresses:
  - "203.0.113.10/32"   # この 1 つの IP だけ対象（管理者 PC など）
  - "198.51.100.0/24"   # 198.51.100.0〜255 の 256 個まとめて対象（社内 VPN サブネットなど）
  - "192.0.2.0/28"      # 192.0.2.0〜15 の 16 個まとめて対象（特定のオフィス回線など）
```

> **ビット数の計算:** ホスト部のビット数 = 32 − `/後の数字`。対象 IP 数 = 2^(ホスト部のビット数)。
> 例: `/24` → ホスト部 8bit → 2^8 = 256 個

---

## 関連ドキュメント

- [ip-restriction.md](./ip-restriction.md) — IP 制限の詳細と実装例
- [cloudfront-setup.md](./cloudfront-setup.md) — WAF + CloudFront の設定手順
- [alb-setup.md](./alb-setup.md) — WAF + ALB の設定手順
- [templates/waf-cloudfront.yaml](./templates/waf-cloudfront.yaml) — CloudFront 用 WAF テンプレート
- [templates/waf-alb.yaml](./templates/waf-alb.yaml) — ALB 用 WAF テンプレート
- [templates/waf-ip-restriction.yaml](./templates/waf-ip-restriction.yaml) — IP 制限特化テンプレート
