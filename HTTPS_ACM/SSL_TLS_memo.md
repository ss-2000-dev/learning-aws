### HTTPS 終端について
- HTTPS ターミネーション、SSL/TLS終端ともいう
- ALB を使うと、通常は ALB で HTTPS を終端 して、その後は HTTP で EC2 に転送される
- ALBはSSL/TLS終端をサポートし、クライアントとの間で暗号化する
- AWSを利用したサービスでインフラを構築するときはALBでHTTPSを終端させる
- ロードバランサーでSSLを終了することはバックエンドサーバーにとってメリットがあります。たとえば、CPUパフォーマンスを節約し、**バックエンドによる復号化を必要としません**、システム全体の処理効率が向上につながる

### これさえ理解していればOK
```
インターネット -> (HTTPS) -> ALB -> (HTTP) -> ECS
```

### 参考記事
- [Okta詳しいけど深堀りすぎない](https://www.okta.com/ja-jp/products/access-gateway/)
- [AWSでWebサイトをHTTPS化 全パターンを整理してみました](https://recipe.kc-cloud.jp/archives/11067/)
- [【簡単！初心者向け！】プロキシサーバとSSL終端(復号)の仕組みをわかりやすく説明！ - AWS研究所](https://se2ls.com/Infra/Proxy/proxy_ssl.html) -> 一番わかりやすかった記事