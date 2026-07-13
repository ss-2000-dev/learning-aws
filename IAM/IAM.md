# IAM と IAM Identity Center の違い

- IAM: Identity and Access Management

## IAM Identity Center

- AWS が提供する ID 管理ソリューションで、AWS SSO（Single Sign-On）の後継として再ブランド化されたもの
- 主な目的は、AWS と非 AWS の両方に対する集中的な ID 管理と SSO の有効化
  - ID ソース: ユーザー ID の保存先として、Identity Center のディレクトリ、Active Directory (AD)、または SAML 2.0 プロトコルを使用する標準プロバイダー（Okta など）を利用できる
  - 連携: オンプレミスの AD との接続には、AD Connector または AWS Managed Microsoft AD を使用できる
- アクセス先: AWS サービスに加えて、外部のビジネスアプリケーション（Office 365、Salesforce など）も
- マルチアカウント: 単一のログインで、組織内の複数のアカウントへのアクセス権付与が容易
- フェデレーション: 外部 IdP との組み込みフェデレーションを備え、セットアップと管理が容易
- ユースケース: AWS 内のリソース権限管理、IAM ユーザー・ロールの作成管理、AWS への SSO のための外部 IdP とのフェデレーション設定

## IAM

- 目的: AWS サービスとリソースへのアクセスを管理
- アクセス先: AWS サービスに限定
- マルチアカウント: 複雑なクロスアカウントロール設定が必要
- フェデレーション: SAML/OpenID Connect を使用するフェデレーションをサポートするが、より複雑な設定が必要
- ユースケース: AWS リソースと非 AWS アプリケーションの両方に対する SSO、複雑な環境における集中的な ID 管理、外部ディレクトリサービスとの統合の簡素化
- AWS マネジメントコンソールのダッシュボードは、IAM ユーザーごとに表示される内容やアクセスできる機能が異なる
  - IAM（Identity and Access Management）によって各ユーザーに割り当てられた**アクセス許可（ポリシー）**に基づいている

## 信頼ポリシー
- 誰が（どのIAMユーザー、IAMロール、AWSアカウントなどが）、そのロールを引き受ける（使用する）ことを許可されるかを定義
- ユーザーやサービスは、本来自分が持っていない権限を一時的に借用し、特定のリソースに安全にアクセスできるようになる
- [IAM ロールの PassRole と AssumeRole をもう二度と忘れないために絵を描いてみた](https://dev.classmethod.jp/articles/iam-role-passrole-assumerole/)
ex.
```
{
  "Version":"2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": { "Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }
  ]
}
```
