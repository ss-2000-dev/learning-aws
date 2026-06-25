# AWS WAF Web Application Firewall

- AWS が提供する Web Application Firewall
- HTTP(S) リクエストをモニタリングできるウェブアプリケーションファイアウォール
- Web アプリケーションに対する攻撃から対象のリソースを保護する
  - 対象のリソース：CloudFront, ALB, API Gateway
- 指定されたルールに基づいてトラフィックを許可/ブロックする
- XSS, SQL インジェクション、CSRF などの攻撃・脆弱性を検出・防止するための機能を提供する
- Web ACL：制御ルールを含んだ論理的なグループのこと

## ルール

- Statement：条件
- Action：条件に一致した場合のアクション
  - ALLOW
  - BLOCK
  - COUNT：リクエストがあったことをカウントするだけで、アクションは実施しない
  - CAPTCHA, Challenge：ボットかどうか判定
- AWS マネージドルールグループ：あらかじめ用意してくれているルール

## ドキュメント・テンプレート一覧

- [README.md](./README.md) — WAF 概要・設定全般の詳細ドキュメント
- [ip-restriction.md](./ip-restriction.md) — IP 制限の解説と実装パターン
- [cloudfront-setup.md](./cloudfront-setup.md) — WAF + CloudFront の設定手順
- [alb-setup.md](./alb-setup.md) — WAF + ALB の設定手順
- [templates/waf-cloudfront.yaml](./templates/waf-cloudfront.yaml) — CloudFront 用 WAF テンプレート（商用フルセット）
- [templates/waf-alb.yaml](./templates/waf-alb.yaml) — ALB 用 WAF テンプレート（商用フルセット）
- [templates/waf-ip-restriction.yaml](./templates/waf-ip-restriction.yaml) — IP 制限特化テンプレート
