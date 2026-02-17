# DNS について

- AWS ACM, SSL/TLS 証明書を理解するにあたり、DNS について深掘りしたくなったのでそのときのメモ
- DNS の簡単な説明は省く

## DNS のレコード

- DNS は１つのドメインに対して複数の情報を持てる
- その１つ１つの情報を DNS レコードと呼ぶ
- なぜレコードが必要なのか？　 → 　１つのドメインに「IP」「メール設定」「所有者証明」「別名」など複数の用途があるから。
- DNS は「ドメイン名に紐づく設定をまとめたデータベース」、レコードはそのテーブル内の列に近い

レコードの種類
| レコード | 内容 | 具体例（名前） | 具体例（値） |
| --------- | ------------------------ | ----------------------------------------- | -------------------------------------- |
| **A** | ドメイン → IPv4 アドレス | example.com | 93.184.216.34 |
| **AAAA** | ドメイン → IPv6 アドレス | example.com | 2606:2800:220:1:248:1893:25c8:1946 |
| **CNAME** | 別名 → 正規名 | [www.example.com](http://www.example.com) | example.com |
| **TXT** | 任意の文字列を保存するレコード | example.com | "v=spf1 include:\_spf.google.com ~all" |
| **MX** | メールサーバ設定 | example.com | 10 mail.example.com |
| **NS** | そのドメインを管理するネームサーバの情報 | example.com | ns1.example-dns.com |

## DNS レコード名の由来

- DNS は 1980 年代に設計された古いプロトコルで、名称は当時の議論や RFC（仕様書）に基づき決められている
- 由来は以下のとおり。

### A レコード

A = Address（アドレス）  
→ ホスト名に対して IPv4 アドレスを返すので "Address Record"

### AAAA レコード

AAAA = 4 つの A = 128bit アドレス（IPv6 を示す A の 4 倍）  
→ IPv6 は 128bit（= 32bit の IPv4 の 4 倍）  
→ A×4 なので AAAA（読みは “クアッド A”）

### CNAME レコード

CNAME = Canonical Name（正規名）  
→ 別名（Alias）ではなく、“正規のホスト名” を指す  
Canonical：正規の

### TXT レコード

TXT = Text  
→ 単純にテキストを保存するためのレコード  
（後にドメイン認証や SPF などでも使われるようになった）

### MX レコード

MX = Mail eXchange  
→ メール交換のためのサーバ情報

### NS レコード

NS = Name Server  
→ そのドメインの権威 DNS サーバの情報を示す

## Linux コマンドで DNS レコードを見る

コマンド

- dig
- nslookup
- host

```bash
$ dig google.com ANY

; <<>> DiG 9.18.12-0ubuntu0.22.04.2-Ubuntu <<>> google.com ANY
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 16682
;; flags: qr rd ra; QUERY: 1, ANSWER: 8, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;google.com.                    IN      ANY

;; ANSWER SECTION:
google.com.             41      IN      SOA     ns1.google.com. dns-admin.google.com. 840159899 900 900 1800 60
google.com.             219     IN      A       142.251.42.142
google.com.             124     IN      AAAA    2404:6800:4004:825::200e
google.com.             5121    IN      HTTPS   1 . alpn="h2,h3"
google.com.             134718  IN      NS      ns2.google.com.
google.com.             134718  IN      NS      ns4.google.com.
google.com.             134718  IN      NS      ns1.google.com.
google.com.             134718  IN      NS      ns3.google.com.

;; Query time: 970 msec
;; SERVER: 10.255.255.254#53(10.255.255.254) (TCP)
;; WHEN: Fri Dec 05 22:12:22 JST 2025
;; MSG SIZE  rcvd: 226
```

```bash
$ dig google.com TXT

; <<>> DiG 9.18.12-0ubuntu0.22.04.2-Ubuntu <<>> google.com TXT
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 24896
;; flags: qr rd ra; QUERY: 1, ANSWER: 12, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;google.com.                    IN      TXT

;; ANSWER SECTION:
google.com.             3600    IN      TXT     "MS=E4A68B9AB2BB9670BCE15412F62916164C0B20BB"
google.com.             3600    IN      TXT     "v=spf1 include:_spf.google.com ~all"
google.com.             3600    IN      TXT     "apple-domain-verification=30afIBcvSuDV2PLX"
google.com.             3600    IN      TXT     "google-site-verification=4ibFUgB-wXLQ_S7vsXVomSTVamuOXBiVAzpR5IZ87D0"
google.com.             3600    IN      TXT     "google-site-verification=wD8N7i1JTNTkezJ49swvWW48f8_9xveREV4oB-0Hf5o"
google.com.             3600    IN      TXT     "facebook-domain-verification=22rm551cu4k0ab0bxsw536tlds4h95"
google.com.             3600    IN      TXT     "docusign=05958488-4752-4ef2-95eb-aa7ba8a3bd0e"
google.com.             3600    IN      TXT     "globalsign-smime-dv=CDYX+XFHUw2wml6/Gb8+59BsH31KzUr6c1l2BPvqKX8="
google.com.             3600    IN      TXT     "docusign=1b0a6754-49b1-4db5-8540-d2c12664b289"
google.com.             3600    IN      TXT     "cisco-ci-domain-verification=47c38bc8c4b74b7233e9053220c1bbe76bcc1cd33c7acf7acd36cd6a5332004b"
google.com.             3600    IN      TXT     "onetrust-domain-verification=de01ed21f2fa4d8781cbc3ffb89cf4ef"
google.com.             3600    IN      TXT     "google-site-verification=TV9-DBe4R80X4v0M4U_bd_J9cpOJM0nikft0jAgjmsQ"

;; Query time: 20 msec
;; SERVER: 10.255.255.254#53(10.255.255.254) (UDP)
;; WHEN: Fri Dec 05 22:13:23 JST 2025
;; MSG SIZE  rcvd: 886
```

```bash
$ dig gmail.com MX

; <<>> DiG 9.18.12-0ubuntu0.22.04.2-Ubuntu <<>> gmail.com MX
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 885
;; flags: qr rd ra; QUERY: 1, ANSWER: 5, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
;; QUESTION SECTION:
;gmail.com.                     IN      MX

;; ANSWER SECTION:
gmail.com.              3600    IN      MX      10 alt1.gmail-smtp-in.l.google.com.
gmail.com.              3600    IN      MX      40 alt4.gmail-smtp-in.l.google.com.
gmail.com.              3600    IN      MX      30 alt3.gmail-smtp-in.l.google.com.
gmail.com.              3600    IN      MX      20 alt2.gmail-smtp-in.l.google.com.
gmail.com.              3600    IN      MX      5 gmail-smtp-in.l.google.com.

;; Query time: 50 msec
;; SERVER: 10.255.255.254#53(10.255.255.254) (UDP)
;; WHEN: Fri Dec 05 22:14:06 JST 2025
;; MSG SIZE  rcvd: 161
```

## メモ

- 証明書とは？
- ネームサーバの仕組みからの説明
- DNS の権威サーバ・キャッシュ DNS の違い
- そのドメインを管理するネームサーバの情報
- ACME プロトコル（Let’s Encrypt が使う仕組み）
- 証明書チェーンとルート CA
- ハンドシェイクの詳細（ECDHE、署名、鍵共有など）
