# SSL/TSL 証明書メモ

## そもそも Web の世界における証明書とは？

- そのサーバが本当にそのドメインの“正しい持ち主”であり、通信が安全であることを証明するデジタル書類
- 公開鍵の正当性（この公開鍵はこのドメインのものですよ）を、信頼できる第三者が保証する文書
- 「その公開鍵、実は攻撃者が偽装して配布しているんじゃ？」  
  → この不安を解消するために、
  「この公開鍵は example.com の正当な持ち主のものです」
  という保証を、信頼された認証局（CA）が発行する。

## SSL/TLS とは？

SSL/TLS はプロトコル

- SSL（Secure Sockets Layer）：古い世代の暗号化通信プロトコル（現在は非推奨）
- TLS（Transport Layer Security）：SSL の後継で、現在の標準

TLS の中で

- 鍵交換方式（RSA/ECDHE）
- 暗号化方式（AES/GCM など）
- ハッシュ関数（SHA-256 など）

などを組み合わせて、安全な通信路を作っている

## SSL/TLS 証明書とは何か？

Web の安全な通信（HTTPS）で使われる証明書で、サーバの公開鍵と、ドメインの正当性を保証する情報が入っている。  
内容
| 項目 | 意味 |
| -------------- | --------------------- |
| ドメイン名（CN, SAN） | この証明書が有効なドメイン |
| 公開鍵 | サーバが持つ「公開鍵」 |
| 有効期限 | いつまで使えるか |
| 発行者（CA, Certification Authority） | どの認証局が発行したか |
| 署名 | CA が証明書の正当性を数学的に保証した印 |

## SSL/TLS 証明書の発行手順

1. サーバ側で秘密鍵と公開鍵を作る
2. サーバ側で CSR Certificate Siging Request を作成（証明書の“申し込み書”）
3. CA がドメインの所有者確認をする（DNS validation など）
4. CA が証明書を発行する

### 2. CSR の作成

CSR の中身
| 項目 | 説明 |
| --------------------- | --------------------- |
| ドメイン名（CN） | 証明書を使いたいドメイン名 |
| 組織名 | 会社名（OV 証明書以上で使用） |
| 国名 | JP など |
| 公開鍵 | 先ほど生成した公開鍵 |
| **秘密鍵で CSR にデジタル署名した印** | 「この公開鍵を持っているのは私です」を証明 |

- CSR の最も重要ポイント：**CSR 内に入っている公開鍵は「秘密鍵とペアのもの」かどうか、CA は厳密に検証する**

### 4. CA が証明書を発行する

発行手順

1. CSR の内容を使って証明書を作成
2. **CA の秘密鍵**で証明書に“署名”
3. 完成した証明書を返す（公開鍵、SAN、発行者、有効期限などを含む）

## SSL/TLS 証明書の内部構造

- 証明書は「公開鍵＋身元情報＋署名」をまとめたデータ構造（X.509 フォーマット）」になっている
- 実体は「特定の ASN.1 構造を DER でエンコードしたバイナリ」。普段はそれを PEM（Base64）形式で見るだけ

### 証明書の主要なフィールド

#### 【1】 Version（バージョン）

- 通常は X.509 version 3。

#### 【2】 Serial Number（シリアル番号）

- CA が発行した証明書を識別するための一意の番号。

#### 【3】 Signature Algorithm（署名アルゴリズム）

- CA が証明書に署名する際に使ったアルゴリズム
  例：sha256WithRSAEncryption

#### 【4】 Issuer（発行者）

- 証明書を発行した CA の情報  
  例：`CN=DigiCert Global Root CA, O=DigiCert Inc`

#### 【5】 Validity（有効期間）

- Not Before
- Not After

#### 【6】 Subject（証明書の対象）

- 「この証明書は誰のための物か」  
   ここに CN（Common Name）などが含まれる。  
   例：`C=JP, ST=Tokyo, O=Example Corp, CN=example.com`

#### 【7】 Subject Public Key Info（公開鍵）

- 公開鍵のアルゴリズム（RSA/ECDSA）
- 公開鍵そのもの

#### 【8】 Extensions（拡張領域：v3 で導入）

**重要**  
主な拡張：

- Subject Alternative Name（SAN）
  - 例：DNS: example.com, DNS: www.example.com
- Key Usage
  - 例：digitalSignature, keyEncipherment
- Extended Key Usage
  - 例：serverAuth, clientAuth
- Basic Constraints
  - 例：CA:FALSE（通常のサーバ証明書）
- CRL Distribution Points / OCSP
  - 失効管理に必要

#### 【9】 CA の署名（Signature）

- Issuer によって、Subject + Public Key 情報が改ざんされていないことを保証する。

#### 全体像：証明書の役割

| 目的             | 証明書のどの情報が使われるか      |
| ---------------- | --------------------------------- |
| サーバの身元証明 | Subject（CN/SAN）                 |
| なりすまし防止   | CA の署名                         |
| 暗号化の準備     | 公開鍵（Subject Public Key Info） |
| 有効期間の管理   | Validity                          |
| 失効チェック     | CRL/OCSP (extensions)             |

## 証明書の例

```bash
echo | openssl s_client -connect google.com:443 -servername google.com 2>/dev/null | openssl x509 -noout -text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number:
            9d:9e:d0:e1:cc:0e:cc:84:0a:04:2e:3c:2f:9e:d5:71
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = US, O = Google Trust Services, CN = WR2
        Validity
            Not Before: Oct 27 08:33:43 2025 GMT
            Not After : Jan 19 08:33:42 2026 GMT
        Subject: CN = *.google.com
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:f1:e0:e6:51:dd:4a:32:d8:cf:c3:e1:44:e1:96:
                    a3:7b:a0:a4:fd:18:54:67:5d:15:87:a9:4c:d3:a2:
                    0f:ea:dd:84:48:dc:3b:a3:87:f2:3d:d0:13:b2:40:
                    f6:d2:b8:45:73:71:8d:c7:26:2b:69:7a:20:e9:21:
                    58:e3:c3:cf:54
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Key Usage: critical
                Digital Signature
            X509v3 Extended Key Usage:
                TLS Web Server Authentication
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier:
                37:07:29:A3:52:3A:AE:2E:A7:26:05:0F:43:26:FA:F1:71:3E:0A:04
            X509v3 Authority Key Identifier:
                DE:1B:1E:ED:79:15:D4:3E:37:24:C3:21:BB:EC:34:39:6D:42:B2:30
            Authority Information Access:
                OCSP - URI:http://o.pki.goog/wr2
                CA Issuers - URI:http://i.pki.goog/wr2.crt
            X509v3 Subject Alternative Name:
                DNS:*.google.com, DNS:*.appengine.google.com, DNS:*.bdn.dev, DNS:*.origin-test.bdn.dev, DNS:*.cloud.google.com, DNS:*.crowdsource.google.com, DNS:*.datacompute.google.com, DNS:*.google.ca, DNS:*.google.cl, DNS:*.google.co.in, DNS:*.google.co.jp, DNS:*.google.co.uk, DNS:*.google.com.ar, DNS:*.google.com.au, DNS:*.google.com.br, DNS:*.google.com.co, DNS:*.google.com.mx, DNS:*.google.com.tr, DNS:*.google.com.vn, DNS:*.google.de, DNS:*.google.es, DNS:*.google.fr, DNS:*.google.hu, DNS:*.google.it, DNS:*.google.nl, DNS:*.google.pl, DNS:*.google.pt, DNS:*.googleapis.cn, DNS:*.googlevideo.com, DNS:*.gstatic.cn, DNS:*.gstatic-cn.com, DNS:googlecnapps.cn, DNS:*.googlecnapps.cn, DNS:googleapps-cn.com, DNS:*.googleapps-cn.com, DNS:gkecnapps.cn, DNS:*.gkecnapps.cn, DNS:googledownloads.cn, DNS:*.googledownloads.cn, DNS:recaptcha.net.cn, DNS:*.recaptcha.net.cn, DNS:recaptcha-cn.net, DNS:*.recaptcha-cn.net, DNS:widevine.cn, DNS:*.widevine.cn, DNS:ampproject.org.cn, DNS:*.ampproject.org.cn, DNS:ampproject.net.cn, DNS:*.ampproject.net.cn, DNS:google-analytics-cn.com, DNS:*.google-analytics-cn.com, DNS:googleadservices-cn.com, DNS:*.googleadservices-cn.com, DNS:googlevads-cn.com, DNS:*.googlevads-cn.com, DNS:googleapis-cn.com, DNS:*.googleapis-cn.com, DNS:googleoptimize-cn.com, DNS:*.googleoptimize-cn.com, DNS:doubleclick-cn.net, DNS:*.doubleclick-cn.net, DNS:*.fls.doubleclick-cn.net, DNS:*.g.doubleclick-cn.net, DNS:doubleclick.cn, DNS:*.doubleclick.cn, DNS:*.fls.doubleclick.cn, DNS:*.g.doubleclick.cn, DNS:dartsearch-cn.net, DNS:*.dartsearch-cn.net, DNS:googletraveladservices-cn.com, DNS:*.googletraveladservices-cn.com, DNS:googletagservices-cn.com, DNS:*.googletagservices-cn.com, DNS:googletagmanager-cn.com, DNS:*.googletagmanager-cn.com, DNS:googlesyndication-cn.com, DNS:*.googlesyndication-cn.com, DNS:*.safeframe.googlesyndication-cn.com, DNS:app-measurement-cn.com, DNS:*.app-measurement-cn.com, DNS:gvt1-cn.com, DNS:*.gvt1-cn.com, DNS:gvt2-cn.com, DNS:*.gvt2-cn.com, DNS:2mdn-cn.net, DNS:*.2mdn-cn.net, DNS:googleflights-cn.net, DNS:*.googleflights-cn.net, DNS:admob-cn.com, DNS:*.admob-cn.com, DNS:*.gemini.cloud.google.com, DNS:googlesandbox-cn.com, DNS:*.googlesandbox-cn.com, DNS:*.safenup.googlesandbox-cn.com, DNS:*.gstatic.com, DNS:*.metric.gstatic.com, DNS:*.gvt1.com, DNS:*.gcpcdn.gvt1.com, DNS:*.gvt2.com, DNS:*.gcp.gvt2.com, DNS:*.url.google.com, DNS:*.youtube-nocookie.com, DNS:*.ytimg.com, DNS:ai.android, DNS:android.com, DNS:*.android.com, DNS:*.flash.android.com, DNS:g.cn, DNS:*.g.cn, DNS:g.co, DNS:*.g.co, DNS:goo.gl, DNS:www.goo.gl, DNS:google-analytics.com, DNS:*.google-analytics.com, DNS:google.com, DNS:googlecommerce.com, DNS:*.googlecommerce.com, DNS:ggpht.cn, DNS:*.ggpht.cn, DNS:urchin.com, DNS:*.urchin.com, DNS:youtu.be, DNS:youtube.com, DNS:*.youtube.com, DNS:music.youtube.com, DNS:*.music.youtube.com, DNS:youtubeeducation.com, DNS:*.youtubeeducation.com, DNS:youtubekids.com, DNS:*.youtubekids.com, DNS:yt.be, DNS:*.yt.be, DNS:android.clients.google.com, DNS:*.android.google.cn, DNS:*.chrome.google.cn, DNS:*.developers.google.cn, DNS:*.aistudio.google.com
            X509v3 Certificate Policies:
                Policy: 2.23.140.1.2.1
            X509v3 CRL Distribution Points:
                Full Name:
                  URI:http://c.pki.goog/wr2/GSyT1N4PBrg.crl
            CT Precertificate SCTs:
                Signed Certificate Timestamp:
                    Version   : v1 (0x0)
                    Log ID    : 96:97:64:BF:55:58:97:AD:F7:43:87:68:37:08:42:77:
                                E9:F0:3A:D5:F6:A4:F3:36:6E:46:A4:3F:0F:CA:A9:C6
                    Timestamp : Oct 27 09:33:46.163 2025 GMT
                    Extensions: none
                    Signature : ecdsa-with-SHA256
                                30:45:02:21:00:C6:F0:6C:EF:D3:FA:6B:61:0F:8A:C7:
                                09:BA:20:A9:EB:E9:3A:6E:EB:6B:CF:2A:86:C0:80:A8:
                                F8:B7:1F:18:1D:02:20:2A:4A:73:19:46:EB:BD:A9:04:
                                04:3A:7F:9E:75:ED:A9:E5:BC:B3:3A:FE:A3:D0:E6:AA:
                                48:C5:3A:94:3A:97:E5
                Signed Certificate Timestamp:
                    Version   : v1 (0x0)
                    Log ID    : 19:86:D4:C7:28:AA:6F:FE:BA:03:6F:78:2A:4D:01:91:
                                AA:CE:2D:72:31:0F:AE:CE:5D:70:41:2D:25:4C:C7:D4
                    Timestamp : Oct 27 09:33:46.068 2025 GMT
                    Extensions: none
                    Signature : ecdsa-with-SHA256
                                30:44:02:20:10:07:41:95:3C:B7:97:CC:79:19:29:23:
                                F5:B3:9F:8E:CA:99:33:EE:91:59:8B:31:8E:91:FB:37:
                                3A:3A:BC:E6:02:20:3E:3D:00:96:B8:D9:CE:0A:53:C1:
                                E1:6E:0D:37:84:AD:49:D2:7D:A0:70:98:B4:78:B0:0F:
                                4E:FE:6A:A0:C1:4C
    Signature Algorithm: sha256WithRSAEncryption
    Signature Value:
        4c:12:a4:4f:95:5b:45:2c:34:17:b8:ed:af:6b:4b:34:ac:ac:
        00:c4:98:8f:dc:3b:6b:db:d1:30:61:9d:54:ee:fc:96:b7:05:
        94:bc:aa:cc:28:cb:48:9a:12:f0:28:0a:ce:e8:ea:56:96:dd:
        85:1b:c4:7f:56:6a:ed:e6:2f:69:30:20:80:86:64:cf:f0:20:
        03:e6:8a:07:0a:0a:1b:56:3c:a0:68:b5:06:c2:b8:d8:e1:d3:
        e4:ac:d9:82:09:11:e3:22:1a:82:dc:d7:70:03:6c:3e:f7:28:
        93:14:4c:9c:73:d1:ed:10:9f:7c:9c:54:51:68:fa:01:ba:56:
        df:91:fa:6e:8d:4d:73:47:11:3e:af:51:d5:11:f2:dc:d0:74:
        06:dc:88:9b:5b:82:41:a7:81:3d:82:8c:05:c8:32:42:ca:a3:
        4a:74:7c:4a:91:0d:fa:b2:d1:72:4c:58:4f:d2:c5:a0:94:3a:
        06:11:1f:3c:d6:08:e5:24:5e:d0:70:2a:29:80:41:9c:1f:53:
        e4:8e:9f:01:9d:0e:e6:14:e1:9c:ab:70:17:01:7e:7c:53:14:
        d4:e4:0a:03:e4:a7:d1:c6:4b:6c:a4:a4:38:09:05:75:85:47:
        dc:27:c0:aa:e8:cd:e4:2a:9c:d3:06:9b:7d:92:80:16:49:04:
        97:29:73:30
```

- s_client -connect: HTTPS サイトに接続
- servername: SNI（Server Name Indication）
- openssl x509 -noout -text: 証明書の内部構造を人間に読める形式で表示

普段はそれを PEM（Base64）形式で見るだけ

- PEM が Base64 エンコードされているのを知らなかった

```bash
echo | openssl s_client -connect google.com:443 -servername google.com 2>/dev/null | openssl x509
-----BEGIN CERTIFICATE-----
MIIOSDCCDTCgAwIBAgIRAJ2e0OHMDsyECgQuPC+e1XEwDQYJKoZIhvcNAQELBQAw
OzELMAkGA1UEBhMCVVMxHjAcBgNVBAoTFUdvb2dsZSBUcnVzdCBTZXJ2aWNlczEM
MAoGA1UEAxMDV1IyMB4XDTI1MTAyNzA4MzM0M1oXDTI2MDExOTA4MzM0MlowFzEV
MBMGA1UEAwwMKi5nb29nbGUuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE
8eDmUd1KMtjPw+FE4Zaje6Ck/RhUZ10Vh6lM06IP6t2ESNw7o4fyPdATskD20rhF
c3GNxyYraXog6SFY48PPVKOCDDQwggwwMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUE
DDAKBggrBgEFBQcDATAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQ3BymjUjquLqcm
BQ9DJvrxcT4KBDAfBgNVHSMEGDAWgBTeGx7teRXUPjckwyG77DQ5bUKyMDBYBggr
BgEFBQcBAQRMMEowIQYIKwYBBQUHMAGGFWh0dHA6Ly9vLnBraS5nb29nL3dyMjAl
BggrBgEFBQcwAoYZaHR0cDovL2kucGtpLmdvb2cvd3IyLmNydDCCCgsGA1UdEQSC
CgIwggn+ggwqLmdvb2dsZS5jb22CFiouYXBwZW5naW5lLmdvb2dsZS5jb22CCSou
YmRuLmRldoIVKi5vcmlnaW4tdGVzdC5iZG4uZGV2ghIqLmNsb3VkLmdvb2dsZS5j
b22CGCouY3Jvd2Rzb3VyY2UuZ29vZ2xlLmNvbYIYKi5kYXRhY29tcHV0ZS5nb29n
bGUuY29tggsqLmdvb2dsZS5jYYILKi5nb29nbGUuY2yCDiouZ29vZ2xlLmNvLmlu
gg4qLmdvb2dsZS5jby5qcIIOKi5nb29nbGUuY28udWuCDyouZ29vZ2xlLmNvbS5h
coIPKi5nb29nbGUuY29tLmF1gg8qLmdvb2dsZS5jb20uYnKCDyouZ29vZ2xlLmNv
bS5jb4IPKi5nb29nbGUuY29tLm14gg8qLmdvb2dsZS5jb20udHKCDyouZ29vZ2xl
LmNvbS52boILKi5nb29nbGUuZGWCCyouZ29vZ2xlLmVzggsqLmdvb2dsZS5mcoIL
Ki5nb29nbGUuaHWCCyouZ29vZ2xlLml0ggsqLmdvb2dsZS5ubIILKi5nb29nbGUu
cGyCCyouZ29vZ2xlLnB0gg8qLmdvb2dsZWFwaXMuY26CESouZ29vZ2xldmlkZW8u
Y29tggwqLmdzdGF0aWMuY26CECouZ3N0YXRpYy1jbi5jb22CD2dvb2dsZWNuYXBw
cy5jboIRKi5nb29nbGVjbmFwcHMuY26CEWdvb2dsZWFwcHMtY24uY29tghMqLmdv
b2dsZWFwcHMtY24uY29tggxna2VjbmFwcHMuY26CDiouZ2tlY25hcHBzLmNughJn
b29nbGVkb3dubG9hZHMuY26CFCouZ29vZ2xlZG93bmxvYWRzLmNughByZWNhcHRj
aGEubmV0LmNughIqLnJlY2FwdGNoYS5uZXQuY26CEHJlY2FwdGNoYS1jbi5uZXSC
EioucmVjYXB0Y2hhLWNuLm5ldIILd2lkZXZpbmUuY26CDSoud2lkZXZpbmUuY26C
EWFtcHByb2plY3Qub3JnLmNughMqLmFtcHByb2plY3Qub3JnLmNughFhbXBwcm9q
ZWN0Lm5ldC5jboITKi5hbXBwcm9qZWN0Lm5ldC5jboIXZ29vZ2xlLWFuYWx5dGlj
cy1jbi5jb22CGSouZ29vZ2xlLWFuYWx5dGljcy1jbi5jb22CF2dvb2dsZWFkc2Vy
dmljZXMtY24uY29tghkqLmdvb2dsZWFkc2VydmljZXMtY24uY29tghFnb29nbGV2
YWRzLWNuLmNvbYITKi5nb29nbGV2YWRzLWNuLmNvbYIRZ29vZ2xlYXBpcy1jbi5j
b22CEyouZ29vZ2xlYXBpcy1jbi5jb22CFWdvb2dsZW9wdGltaXplLWNuLmNvbYIX
Ki5nb29nbGVvcHRpbWl6ZS1jbi5jb22CEmRvdWJsZWNsaWNrLWNuLm5ldIIUKi5k
b3VibGVjbGljay1jbi5uZXSCGCouZmxzLmRvdWJsZWNsaWNrLWNuLm5ldIIWKi5n
LmRvdWJsZWNsaWNrLWNuLm5ldIIOZG91YmxlY2xpY2suY26CECouZG91YmxlY2xp
Y2suY26CFCouZmxzLmRvdWJsZWNsaWNrLmNughIqLmcuZG91YmxlY2xpY2suY26C
EWRhcnRzZWFyY2gtY24ubmV0ghMqLmRhcnRzZWFyY2gtY24ubmV0gh1nb29nbGV0
cmF2ZWxhZHNlcnZpY2VzLWNuLmNvbYIfKi5nb29nbGV0cmF2ZWxhZHNlcnZpY2Vz
LWNuLmNvbYIYZ29vZ2xldGFnc2VydmljZXMtY24uY29tghoqLmdvb2dsZXRhZ3Nl
cnZpY2VzLWNuLmNvbYIXZ29vZ2xldGFnbWFuYWdlci1jbi5jb22CGSouZ29vZ2xl
dGFnbWFuYWdlci1jbi5jb22CGGdvb2dsZXN5bmRpY2F0aW9uLWNuLmNvbYIaKi5n
b29nbGVzeW5kaWNhdGlvbi1jbi5jb22CJCouc2FmZWZyYW1lLmdvb2dsZXN5bmRp
Y2F0aW9uLWNuLmNvbYIWYXBwLW1lYXN1cmVtZW50LWNuLmNvbYIYKi5hcHAtbWVh
c3VyZW1lbnQtY24uY29tggtndnQxLWNuLmNvbYINKi5ndnQxLWNuLmNvbYILZ3Z0
Mi1jbi5jb22CDSouZ3Z0Mi1jbi5jb22CCzJtZG4tY24ubmV0gg0qLjJtZG4tY24u
bmV0ghRnb29nbGVmbGlnaHRzLWNuLm5ldIIWKi5nb29nbGVmbGlnaHRzLWNuLm5l
dIIMYWRtb2ItY24uY29tgg4qLmFkbW9iLWNuLmNvbYIZKi5nZW1pbmkuY2xvdWQu
Z29vZ2xlLmNvbYIUZ29vZ2xlc2FuZGJveC1jbi5jb22CFiouZ29vZ2xlc2FuZGJv
eC1jbi5jb22CHiouc2FmZW51cC5nb29nbGVzYW5kYm94LWNuLmNvbYINKi5nc3Rh
dGljLmNvbYIUKi5tZXRyaWMuZ3N0YXRpYy5jb22CCiouZ3Z0MS5jb22CESouZ2Nw
Y2RuLmd2dDEuY29tggoqLmd2dDIuY29tgg4qLmdjcC5ndnQyLmNvbYIQKi51cmwu
Z29vZ2xlLmNvbYIWKi55b3V0dWJlLW5vY29va2llLmNvbYILKi55dGltZy5jb22C
CmFpLmFuZHJvaWSCC2FuZHJvaWQuY29tgg0qLmFuZHJvaWQuY29tghMqLmZsYXNo
LmFuZHJvaWQuY29tggRnLmNuggYqLmcuY26CBGcuY2+CBiouZy5jb4IGZ29vLmds
ggp3d3cuZ29vLmdsghRnb29nbGUtYW5hbHl0aWNzLmNvbYIWKi5nb29nbGUtYW5h
bHl0aWNzLmNvbYIKZ29vZ2xlLmNvbYISZ29vZ2xlY29tbWVyY2UuY29tghQqLmdv
b2dsZWNvbW1lcmNlLmNvbYIIZ2dwaHQuY26CCiouZ2dwaHQuY26CCnVyY2hpbi5j
b22CDCoudXJjaGluLmNvbYIIeW91dHUuYmWCC3lvdXR1YmUuY29tgg0qLnlvdXR1
YmUuY29tghFtdXNpYy55b3V0dWJlLmNvbYITKi5tdXNpYy55b3V0dWJlLmNvbYIU
eW91dHViZWVkdWNhdGlvbi5jb22CFioueW91dHViZWVkdWNhdGlvbi5jb22CD3lv
dXR1YmVraWRzLmNvbYIRKi55b3V0dWJla2lkcy5jb22CBXl0LmJlggcqLnl0LmJl
ghphbmRyb2lkLmNsaWVudHMuZ29vZ2xlLmNvbYITKi5hbmRyb2lkLmdvb2dsZS5j
boISKi5jaHJvbWUuZ29vZ2xlLmNughYqLmRldmVsb3BlcnMuZ29vZ2xlLmNughUq
LmFpc3R1ZGlvLmdvb2dsZS5jb20wEwYDVR0gBAwwCjAIBgZngQwBAgEwNgYDVR0f
BC8wLTAroCmgJ4YlaHR0cDovL2MucGtpLmdvb2cvd3IyL0dTeVQxTjRQQnJnLmNy
bDCCAQMGCisGAQQB1nkCBAIEgfQEgfEA7wB2AJaXZL9VWJet90OHaDcIQnfp8DrV
9qTzNm5GpD8PyqnGAAABmiUEPTMAAAQDAEcwRQIhAMbwbO/T+mthD4rHCbogqevp
Om7ra88qhsCAqPi3HxgdAiAqSnMZRuu9qQQEOn+ede2p5byzOv6j0OaqSMU6lDqX
5QB1ABmG1Mcoqm/+ugNveCpNAZGqzi1yMQ+uzl1wQS0lTMfUAAABmiUEPNQAAAQD
AEYwRAIgEAdBlTy3l8x5GSkj9bOfjsqZM+6RWYsxjpH7Nzo6vOYCID49AJa42c4K
U8Hhbg03hK1J0n2gcJi0eLAPTv5qoMFMMA0GCSqGSIb3DQEBCwUAA4IBAQBMEqRP
lVtFLDQXuO2va0s0rKwAxJiP3Dtr29EwYZ1U7vyWtwWUvKrMKMtImhLwKArO6OpW
lt2FG8R/Vmrt5i9pMCCAhmTP8CAD5ooHCgobVjygaLUGwrjY4dPkrNmCCRHjIhqC
3NdwA2w+9yiTFEycc9HtEJ98nFRRaPoBulbfkfpujU1zRxE+r1HVEfLc0HQG3Iib
W4JBp4E9gowFyDJCyqNKdHxKkQ36stFyTFhP0sWglDoGER881gjlJF7QcCopgEGc
H1Pkjp8BnQ7mFOGcq3AXAX58UxTU5AoD5KfRxktspKQ4CQV1hUfcJ8Cq6M3kKpzT
Bpt9koAWSQSXKXMw
-----END CERTIFICATE-----
```

## CN/SAN

### CN（Common Name）

- 証明書の Subject フィールド内にある属性の一つで、かつては「この証明書が有効な主たるホスト名」を表すために使われていた値。  
  例：CN = example.com。

- 歴史的にブラウザは CN をチェックしていたが、現代の仕様・実装では SAN を優先するため、CN のみを頼りにするのは推奨されない。CN は補助的に残ることが多い。
- **CN は Subject の中の “ただの 1 フィールド”**

### SAN（Subject Alternative Name）

- 証明書内の拡張領域（extension）で、この証明書が有効なすべての識別子（ドメイン名・IP・メールアドレス等）を列挙する場所。
- 典型的なエントリタイプ：dNSName（ホスト名／ドメイン）、iPAddress、rfc822Name（メールアドレス）、uniformResourceIdentifier 等。
- 現代のクライアント（ブラウザ等）は SAN に列挙された名前と照合し、それに一致しないと接続を拒否する。
- **SAN は Extension の中の “複数リスト**

## OV/DV/EV

「証明書に対する検証レベル（Validation）」の区分

### DV（Domain Validation）

- 検証内容：ドメインの管理権限があるかのみを確認（DNS レコード、HTTP チャレンジ、メール確認など）。
- 発行スピード：即時〜自動（短時間）で発行可能。
- 用途：ブログ、個人サイト、API、短期間のサービス。
- セキュリティ意味合い：ドメイン所有は証明するが、組織の実在性は保証しない。

### OV（Organization Validation）

- 検証内容：ドメインに加え、申請組織の実在確認（登記情報、電話確認など）を行う。
- 発行スピード：手動確認が入るので DV より遅い。
- 用途：企業サイトやブランドサイトで、訪問者に組織の実在性を示したい場合。
- セキュリティ意味合い：ドメインだけでなく組織の実在性もある程度保証する。

### EV（Extended Validation）

- 検証内容：OV よりさらに厳密な手続き（法的実在性、担当者確認、文書提出など）。
- 発行スピード：最も遅く手続きが煩雑。
- 用途：金融機関、大口取引など信頼性を強調したい場面（ただしブラウザの UI での表示は簡略化傾向）。
- セキュリティ意味合い：発行者が高度に検証した結果であることを示すが、技術的な暗号強度とは無関係。

### 実務上の注意点

- DV は短期間かつ自動化が簡単でコストも低い（Let’s Encrypt 等）。だが「証明書がある＝信頼できる企業」という誤解を生む可能性がある。
- EV の視認的メリットは近年ブラウザで薄れているため、コストに見合うかは判断が必要。
- OV/EV は「組織信頼」を示したいケースで検討するが、費用対効果を見て判断する（多くのサービスは DV で十分）

## パブリック証明書 と プライベート証明書

### パブリック証明書（Public CA 発行）

- 発行元：一般にブラウザ・OS の「信頼されたルート証明書ストア」に登録されている公的 CA（DigiCert, Let’s Encrypt, GlobalSign など）。
- 信頼性：クライアント（一般ユーザのブラウザや OS）がデフォルトで信頼するため、追加設定なしに HTTPS 接続が「信頼済み」となる。
- 用途：パブリックに公開する Web サイト・サービス。

### プライベート証明書（Private CA / 自己署名）

- 発行元：社内のプライベート CA（例：HashiCorp Vault、Active Directory Certificate Services、Smallstep）や自己署名。
- 信頼性：クライアント側にルート CA をあらかじめインストール／信頼させない限り「信頼されない」（ブラウザは警告を出す）。
- 用途：社内システム、テスト環境、マイクロサービス間の内部通信、VPN、IoT の内部認証など。
- 管理上の差分：ルート鍵の保護や配布（クライアントへのルート配布）、証明書発行ポリシー、失効管理（CRL/OCSP）を自分たちで運用する必要がある。

### 利点／欠点のまとめ

- パブリック証明書：利点＝ユーザに追加設定不要。欠点＝取得やコントロールの制限（CA のポリシー遵守、公開ルートに依存）。
- プライベート証明書：利点＝柔軟な発行ポリシー、内部向け自動化が容易。欠点＝クライアントの信頼設定が必要で、誤管理すると重大なリスク。

## 深掘るなら...

- 証明書チェーンとルート CA
- TLS ハンドシェイクで、証明書がどのタイミングでどう使われるか（ECDHE による鍵交換の流れ）
- ブラウザが証明書を検証する仕組み（チェーン構造・ルート/中間 CA）
- ブラウザの DV / OV / EV の区別
- 認証局の例
  - AWS
  - Let's Encrypt：無料の TLS 証明書を提供する認証局
  - DigiCert
  - GlobalSign
- SSL/TLS について
- ECDHE の仕組みを「暗号数学」レベルで理解
- 証明書の内部構造（ASN.1 / DER / 拡張フィールド）を理解
- 実際に openssl s_client でリアルなハンドシェイクを観察したい
