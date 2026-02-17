# ACM AWS Certificate Manager

- AWS が提供する SSL/TLS 証明書の発行、管理、および自動化を行うフルマネージドサービス
- SSL/TLS 証明書の理解もしたい

# 用語

### DNS Validation（DNS 検証）：

- SSL/TLS 証明書は 「このドメインは確かにあなたが管理してますよね？」 を確認しないと発行できない
- 確認方法の 1 つが DNS validation

DNS 検証流れ

1. ACM が「この文字列を DNS に登録してください」と言う
2. その文字列を DNS に TXT レコードとして登録する
3. ACM が DNS をチェックし、指示どおりの TXT レコードがあるか確認
4. あれば「この人がドメインの DNS を操作できる → このドメインの持ち主」と判断
5. 証明書を発行する

### CSR Certificate Siging Request

- 証明書を発行してもらうための申請書
- CSR に含まれる情報
  - どのドメインの証明書を作りたいか（例：example.com）
  - 公開鍵
  - 暗号化関連の設定

### SSL/TLS 証明書

- ブラウザとサーバが安全に通信するための身分証明書
