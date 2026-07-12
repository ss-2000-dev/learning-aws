# IAM → IAM Identity Center 移行ガイド

現在 Excel 台帳 + IAM ユーザーで運用している ID 管理を、AWS IAM Identity Center（旧 AWS SSO）に移行するためのドキュメント群。

## 前提条件

- Identity source は **Identity Center ディレクトリ（AWS 独自の ID ストア）** を利用する
  - 外部 IdP（Okta / Azure AD 等）や AD Connector とのフェデレーションは対象外
- グループ・ポリシーは現在 CloudFormation で管理している（この資産を Identity Center 側にどう引き継ぐかが本ガイドの主眼）
- **管理する AWS アカウントは 1 アカウントのみ**（Identity Center の「複数アカウントへの一括権限配布」というメリットは今回は使わない。移行理由は [01-現状整理と全体方針.md](./01-現状整理と全体方針.md) を参照）
- IAM Identity Center の有効化自体には AWS Organizations が必要（1 アカウントのみでも Organizations の作成・有効化は必須）

## ドキュメント構成

| ドキュメント | 内容 |
|---|---|
| [01-現状整理と全体方針.md](./01-現状整理と全体方針.md) | 現状（Excel台帳 + IAM + CFN）と移行後の対応関係、移行方針 |
| [02-CloudFormation管理方針.md](./02-CloudFormation管理方針.md) | CFN で管理すべきもの／しないほうがよいものの判断基準と結論 |
| [03-移行手順.md](./03-移行手順.md) | 実際の移行手順（フェーズ0〜7） |
| [04-移行後の運用ルール.md](./04-移行後の運用ルール.md) | 移行完了後の入退社・異動・権限変更の運用ルール |
| [05-セッション設定.md](./05-セッション設定.md) | ユーザーインタラクティブ／バックグラウンド／Kiro の3セッションの違いと短縮方法 |
| [06-MFA設定.md](./06-MFA設定.md) | MFA 強制の可否と設定方法、グループ単位で出し分けできない点の注意 |
| [templates/](./templates) | Permission Set / Group / Assignment の CloudFormation サンプル（汎用パラメータ化版） |
| [sample/](./sample) | 具体的なシナリオ（Developers / Infra の2グループ）に基づく移行前後の CFN テンプレートと実践手順 |

## 関連ドキュメント

- [../IAM.md](../IAM.md) — IAM と IAM Identity Center の概念的な違い

## 結論だけ知りたい場合

- **CFN で管理する**: Group（組織構造）、Permission Set（権限定義）、Account Assignment（誰がどのアカウントで何ができるか）
- **CFN で管理しない**: User（氏名・メール等の個人情報。そもそも CFN リソースが存在しない）、Group Membership（入退社で頻繁に変わる）

詳細は [02-CloudFormation管理方針.md](./02-CloudFormation管理方針.md) を参照。
