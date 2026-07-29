# WAF による IP 制限

## IP 制限とは

特定の IP アドレス（または CIDR ブロック）を持つリクエストを**許可またはブロック**する機能。

ユースケース：
- 社内ネットワークや管理者 IP のみ特定パスへのアクセスを許可する
- 攻撃元 IP や悪意あるクローラーの IP をブロックする
- 競合他社や特定ユーザーのアクセスを遮断する

---

## 仕組み

### IP セット（IPSet）

IP アドレスのリストを管理するリソース。Web ACL のルールから参照して使う。

```
IPSet
├── IPv4 アドレス（CIDR 形式）: 例 203.0.113.0/24
└── IPv6 アドレス（CIDR 形式）: 例 2001:db8::/32
```

- 1つの IP セットに最大 **10,000 件** の IP アドレスを登録できる
- IP セットは複数のルールから再利用できる
- CloudFormation や API で動的に更新できる

### IP 制限の種類

| 種類 | 説明 | 用途 |
|---|---|---|
| **ブロックリスト（Denylist）** | リスト内の IP をブロック、それ以外は許可 | 悪意ある IP の遮断 |
| **許可リスト（Allowlist）** | リスト内の IP のみ許可、それ以外はブロック | 管理画面・社内システムの保護 |
| **スコープダウンステートメント** | レートリミットと組み合わせて特定 IP を除外 | 監視ツール IP をレート制限から除外 |

---

## IP 制限のルール優先度設計

WAF はルールを Priority の昇順で評価し、最初に一致したルールのアクションを適用する。
IP 制限では以下の優先度設計が一般的：

```
Priority 0: 許可リスト（管理者 IP）→ 無条件に ALLOW ★最優先
Priority 1: ブロックリスト（悪意ある IP）→ BLOCK
Priority 2: マネージドルールグループ（OWASP 等）
Priority 3: レートリミット
Priority 99: （デフォルトアクション: ALLOW）
```

> **重要:** 許可リストを最優先（最小の Priority）にしないと、管理者 IP がマネージドルールに引っかかってブロックされる可能性がある。

---

## 実装パターン

### パターン 1：許可リスト（ホワイトリスト）

管理者 IP のみ `/admin` パスへのアクセスを許可する例。

```yaml
# 管理者 IP セット
AdminIpSet:
  Type: AWS::WAFv2::IPSet
  Properties:
    Scope: REGIONAL  # ALB の場合。CloudFront の場合は CLOUDFRONT
    IPAddressVersion: IPV4
    Addresses:
      - "203.0.113.10/32"   # 管理者 PC（ダミー）
      - "198.51.100.0/24"   # 社内 VPN（ダミー）

# 管理者以外を /admin からブロックするルール
AdminPathRule:
  Type: AWS::WAFv2::WebACL
  # ... （Web ACL 定義内の Rules に追加）
  Rules:
    - Name: AllowAdminFromAllowedIP
      Priority: 0
      Statement:
        # AND 条件：管理者 IP かつ /admin パス
        AndStatement:
          Statements:
            - IPSetReferenceStatement:
                Arn: !GetAtt AdminIpSet.Arn
            - ByteMatchStatement:
                FieldToMatch:
                  UriPath: {}
                PositionalConstraint: STARTS_WITH
                SearchString: "/admin"
                TextTransformations:
                  - Priority: 0
                    Type: LOWERCASE
      Action:
        Allow: {}
      VisibilityConfig:
        SampledRequestsEnabled: true
        CloudWatchMetricsEnabled: true
        MetricName: AllowAdminFromAllowedIP
```

### パターン 2：ブロックリスト（ブラックリスト）

特定 IP をブロックする例。

```yaml
# ブロック対象 IP セット
BlockIpSet:
  Type: AWS::WAFv2::IPSet
  Properties:
    Scope: REGIONAL
    IPAddressVersion: IPV4
    Addresses:
      - "192.0.2.100/32"    # ブロック対象 IP（ダミー）
      - "192.0.2.0/24"      # ブロック対象 CIDR（ダミー）

# ブロックリストルール
BlockIpRule:
  Name: BlockListedIPs
  Priority: 1
  Statement:
    IPSetReferenceStatement:
      Arn: !GetAtt BlockIpSet.Arn
  Action:
    Block: {}
  VisibilityConfig:
    SampledRequestsEnabled: true
    CloudWatchMetricsEnabled: true
    MetricName: BlockListedIPs
```

### パターン 3：レートリミットで特定 IP を除外

監視ツールや CI/CD パイプラインの IP をレート制限から除外する例。

```yaml
RateLimitRule:
  Name: RateLimit
  Priority: 10
  Statement:
    RateBasedStatement:
      Limit: 5000          # 5分間のリクエスト上限
      AggregateKeyType: IP
      ScopeDownStatement:  # このステートメントに一致するリクエストだけ対象にする
        NotStatement:      # 監視ツール IP は除外（NOT）
          Statement:
            IPSetReferenceStatement:
              Arn: !GetAtt MonitoringIpSet.Arn
  Action:
    Block: {}
```

---

## デフォルトアクションを変更すると IP 制限は解除されるか

**「デフォルトアクションを Block → Allow に変更したら、IP 制限は解除されるか？」**という疑問は実装パターンによって答えが変わる。結論から言うと **IP 制限がどう実装されているかによる**（両方のケースがあり得る）。

### 大前提：ルールとデフォルトアクションの関係

AWS 公式ドキュメント（[Setting the protection pack (web ACL) default action](https://docs.aws.amazon.com/waf/latest/developerguide/web-acl-default-action.html)）の記載：

> AWS WAF applies this [default] action to any web request that makes it through all of the web ACL's rule evaluations **without having a terminating action applied to it**.

つまり：
- **ルールにマッチして Block/Allow（terminating action）が適用されたリクエスト** → そのルールのアクションが確定し、デフォルトアクションは**無関係**
- **どのルールにもマッチしなかったリクエスト** → デフォルトアクションが適用される

「解除されるか」は、IP制限ルールがこのどちらの立ち位置にあるかで変わる。

### パターン A：解除される（許可リスト＝ホワイトリスト方式）

```yaml
DefaultAction: Block          # 原則ブロック
Rules:
  - Name: AllowTrustedIPs
    Statement:
      IPSetReferenceStatement:  # 許可IPリスト
    Action:
      Allow: {}                 # 許可IPだけ Allow
```

- 許可IP以外のリクエストは、どのルールにもマッチせず**デフォルトアクション（Block）**で弾かれていた
- `DefaultAction` を `Allow` に変更すると、**許可IP以外の全リクエストもデフォルトで通過**するようになる
- → **IP 制限は実質的に解除される**（許可リストの意味がなくなる）

### パターン B：解除されない（拒否リスト＝ブラックリスト方式）

```yaml
DefaultAction: Block           # 何らかの理由でデフォルトはブロック
Rules:
  - Name: BlockBadIPs
    Statement:
      IPSetReferenceStatement:  # 拒否したいIPリスト
    Action:
      Block: {}                  # 特定IPを明示的にBlock
```

- 拒否したいIPは、ルールで明示的に `Block`（terminating action）が適用される
- `DefaultAction` を `Allow` に変えても、**そのルール自体は残っているので該当IPは引き続きブロックされる**
- ただし、**このルール以外のどのルールにも該当しない他の一般リクエストは Block → Allow に変わる**（全体としての防御は弱まる）
- → **IP 制限（拒否リスト部分）は解除されない**

### まとめ表

| IPルールの実装 | Action | DefaultAction 変更の影響 |
|---|---|---|
| 許可リスト（Allow rule + Block default） | `Allow` | **解除される**（許可IP以外も通ってしまう） |
| 拒否リスト（Block rule + 何らかの default） | `Block` | **解除されない**（該当IPは引き続きブロック）が、他の未マッチ通信は緩くなる |

### 変更前の確認手順（推奨）

1. **現在の Web ACL のルール一覧とアクションを確認**
   ```bash
   aws wafv2 get-web-acl --name <name> --scope REGIONAL --id <id>
   ```
   Rules 内の各 `Action`（Allow/Block）と `IPSetReferenceStatement` の有無を確認する。

2. **どちらのパターンか判断**
   - IP制限ルールの Action が `Allow` → パターンA（解除される）
   - IP制限ルールの Action が `Block` → パターンB（解除されない）

3. **変更前に Count モードで試す**
   本番影響が心配なら、一時的にルールを `Count` にしてサンプルリクエスト・CloudWatch メトリクスで挙動を確認してから本番反映する。

---

## X-Forwarded-For ヘッダーへの対応

ALB や CloudFront の背後に WAF がある場合、クライアントの実際の IP は `X-Forwarded-For` ヘッダーに入ることがある。

WAF の IP 評価方式：

| 設定 | 説明 |
|---|---|
| `IPSetReferenceStatement`（デフォルト） | リクエストの送信元 IP を評価する |
| `Headers` フィールドで X-Forwarded-For を指定 | XFF ヘッダー内の IP を評価する（偽装リスクに注意） |

> **注意:** X-Forwarded-For ヘッダーはクライアントが偽装できるため、IP 評価に使う場合は信頼できるプロキシ経由のものかを確認すること。CloudFront → ALB 構成では CloudFront が XFF に実際のクライアント IP を付与するので、ALB の WAF では XFF を使って評価するのが正しい。

---

## CloudFormation テンプレート

IP 制限に特化したスタンドアロンテンプレートは [templates/waf-ip-restriction.yaml](./templates/waf-ip-restriction.yaml) を参照。

フル商用設定テンプレートは：
- [templates/waf-cloudfront.yaml](./templates/waf-cloudfront.yaml) — CloudFront 用
- [templates/waf-alb.yaml](./templates/waf-alb.yaml) — ALB 用
