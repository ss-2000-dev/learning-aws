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
