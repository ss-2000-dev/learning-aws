# WAF デフォルトアクションとカスタムレスポンス

## デフォルトアクションとは

Web ACL に設定するフォールバックのアクション。**どのルールにも一致しなかったリクエスト**に対して適用される。

```
リクエスト受信
    │
    ├─ Priority 0 のルールに一致？ → アクション実行（ALLOW / BLOCK / COUNT）
    ├─ Priority 1 のルールに一致？ → アクション実行
    ├─ ...
    └─ どれにも一致しなかった → デフォルトアクション を適用
```

---

## デフォルトアクションの種類

| アクション | 挙動 | 用途 |
|---|---|---|
| `Allow` | 許可（リクエストをオリジンに転送） | **ブラックリスト方式**（悪いものだけブロック） |
| `Block` | ブロック（デフォルト 403 を返す） | **ホワイトリスト方式**（許可したものだけ通す） |

### ブラックリスト方式（デフォルト Allow）

通常の Web サービスに使う一般的な設定。悪意あるリクエストのみルールでブロックし、それ以外は全部通す。

```
[許可リスト] → ALLOW
[ブロックリスト] → BLOCK
[マネージドルール] → BLOCK
[レートリミット] → BLOCK
[どれにも一致しない] → デフォルト ALLOW ← 一般ユーザーはここを通る
```

### ホワイトリスト方式（デフォルト Block）

社内システムや管理画面など、アクセスできる IP・条件を完全に絞りたい場合に使う。
許可ルールに一致しない限りすべてブロックされる。

```
[許可リスト IP] → ALLOW
[特定パス + 認証済みヘッダー] → ALLOW
[どれにも一致しない] → デフォルト BLOCK ← 未知のアクセスはすべて弾く
```

---

## デフォルトアクションにカスタムレスポンスは設定できない

> **重要な制約:** デフォルトアクション（`DefaultAction`）の `Block` にはカスタムレスポンスを設定**できない**。

カスタムレスポンス（ステータスコードやボディの変更）を設定できるのは**ルールレベルの `Action`** のみ。

```yaml
# NG: DefaultAction の Block にカスタムレスポンスは指定できない
DefaultAction:
  Block:
    CustomResponse:       # ← これは書けない（CloudFormation エラーになる）
      ResponseCode: 404

# OK: ルールレベルの Action には指定できる
Rules:
  - Name: BlockSomeRule
    Action:
      Block:
        CustomResponse:   # ← ルールのアクションならカスタムレスポンスを設定できる
          ResponseCode: 404
```

---

## カスタムレスポンスとは

ルールが `Block` を実行したときに返す HTTP レスポンスをカスタマイズできる機能。

設定できる項目：

| 項目 | 説明 | デフォルト |
|---|---|---|
| `ResponseCode` | HTTP ステータスコード | `403` |
| `CustomResponseBodyKey` | 返すレスポンスボディのキー（Web ACL で事前定義） | なし（空ボディ） |
| `ResponseHeaders` | 追加するレスポンスヘッダー | なし |

---

## ステータスコードの使い分け

| コード | 意味 | WAF での使い所 |
|---|---|---|
| `400` | Bad Request | リクエスト形式が不正（SQLi / XSS 検出時など） |
| `403` | Forbidden | IP ブロック・権限なし（最も一般的） |
| `404` | Not Found | 存在を隠したいとき（管理画面パスのブロックに有効） |
| `429` | Too Many Requests | レートリミット超過時（意味的に正確） |
| `503` | Service Unavailable | メンテナンス等の一時的なブロック時 |

### 404 を使うべきケース

攻撃者に「このパスが存在する」ことを教えないためにあえて 404 を返す。

```
GET /admin → 403 Forbidden を返すと「/admin は存在するが権限がない」とわかってしまう
GET /admin → 404 Not Found を返すと「/admin 自体が存在しない」と思わせられる
```

---

## CloudFormation での設定方法

### カスタムレスポンスボディの定義

カスタムボディは Web ACL レベルで `CustomResponseBodies` に定義し、ルールから `CustomResponseBodyKey` で参照する。

```yaml
WebACL:
  Type: AWS::WAFv2::WebACL
  Properties:
    # レスポンスボディを事前定義する（複数定義可能）
    CustomResponseBodies:
      # キー名は任意。ルールから CustomResponseBodyKey で参照する
      JsonForbidden:
        ContentType: APPLICATION_JSON
        Content: '{"error":"Forbidden","message":"Access denied."}'

      JsonRateLimit:
        ContentType: APPLICATION_JSON
        Content: '{"error":"TooManyRequests","message":"Rate limit exceeded. Please try again later."}'

      HtmlNotFound:
        ContentType: TEXT_HTML
        Content: '<html><body><h1>404 Not Found</h1></body></html>'

      PlainText:
        ContentType: TEXT_PLAIN
        Content: 'Access Denied'
```

### ルールでのカスタムレスポンス指定

```yaml
Rules:
  # ---- IP ブロック → 403 + JSON レスポンス ----
  - Name: BlockListedIPs
    Priority: 1
    Statement:
      IPSetReferenceStatement:
        Arn: !GetAtt BlockIpSet.Arn
    Action:
      Block:
        CustomResponse:
          ResponseCode: 403
          CustomResponseBodyKey: JsonForbidden   # 上で定義したキーを参照

  # ---- 管理画面パス → 404（存在を隠す）----
  - Name: ProtectAdminPaths
    Priority: 9
    Statement:
      ByteMatchStatement:
        FieldToMatch:
          UriPath: {}
        PositionalConstraint: STARTS_WITH
        SearchString: /admin
        TextTransformations:
          - Priority: 0
            Type: LOWERCASE
    Action:
      Block:
        CustomResponse:
          ResponseCode: 404
          CustomResponseBodyKey: HtmlNotFound

  # ---- レートリミット超過 → 429 + カスタムヘッダー ----
  - Name: RateLimit
    Priority: 8
    Statement:
      RateBasedStatement:
        Limit: 5000
        AggregateKeyType: IP
    Action:
      Block:
        CustomResponse:
          ResponseCode: 429
          CustomResponseBodyKey: JsonRateLimit
          # Retry-After ヘッダーを付けてクライアントに再試行を促す
          ResponseHeaders:
            - Name: Retry-After
              Value: "60"
            - Name: X-Block-Reason
              Value: "rate-limit-exceeded"
```

---

## ホワイトリスト方式の完全な例（デフォルト Block）

社内システムや管理者専用ツールなど、特定の IP・条件以外は一切アクセスさせたくない場合の設定。

```yaml
WebACL:
  Type: AWS::WAFv2::WebACL
  Properties:
    Name: internal-system-waf
    Scope: REGIONAL
    # デフォルト BLOCK: 許可ルールに一致しない限りすべてブロック
    DefaultAction:
      Block: {}   # カスタムレスポンスは設定不可（ルールレベルで設定すること）

    CustomResponseBodies:
      JsonForbidden:
        ContentType: APPLICATION_JSON
        Content: '{"error":"Forbidden","message":"Access is restricted."}'

    Rules:
      # 許可リスト IP からのアクセスのみ通す
      - Name: AllowFromTrustedIPs
        Priority: 0
        Statement:
          IPSetReferenceStatement:
            Arn: !GetAtt AllowIpSet.Arn
        Action:
          Allow: {}
        VisibilityConfig:
          SampledRequestsEnabled: true
          CloudWatchMetricsEnabled: true
          MetricName: AllowFromTrustedIPs

      # ヘルスチェックパスは IP 制限なしで許可
      - Name: AllowHealthCheck
        Priority: 1
        Statement:
          ByteMatchStatement:
            FieldToMatch:
              UriPath: {}
            PositionalConstraint: EXACTLY
            SearchString: /health
            TextTransformations:
              - Priority: 0
                Type: NONE
        Action:
          Allow: {}
        VisibilityConfig:
          SampledRequestsEnabled: true
          CloudWatchMetricsEnabled: true
          MetricName: AllowHealthCheck

      # 上記どれにも一致しない → DefaultAction の Block が適用される
```

---

## サンプルテンプレート

カスタムレスポンスを含む完全な例は [templates/waf-custom-response-example.yaml](./templates/waf-custom-response-example.yaml) を参照。
