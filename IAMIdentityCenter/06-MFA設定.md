# MFA 設定

IAM Identity Center でユーザーの MFA（多要素認証）を強制できるかどうか、および設定方法をまとめる。

> **前提**: MFA 機能は Identity source が **Identity Center ディレクトリ**（または AWS Managed Microsoft AD / AD Connector）の場合のみ利用できる。**外部 IdP 連携の場合は MFA がサポートされない**。今回の移行方針（[README.md](./README.md) 参照）は Identity Center ディレクトリのみを利用するため、MFA 機能はフルに使える。

## 結論

**強制できる。** デフォルトで MFA は有効になっており、ユーザー名・パスワードに加えて第2要素（認証アプリのコード／セキュリティキー／生体認証）が必要な状態になっている。

## 設定場所

IAM Identity Center コンソール → **Settings** → **Authentication** タブ → **Multi-factor authentication** セクション → **Configure**

## 「MFA未登録ユーザー」への対応方法（4択）

| 選択肢 | 動作 |
|---|---|
| **MFAデバイスをサインイン時に登録させる**（デフォルト） | パスワード認証成功後、その場で MFA デバイスをセルフ登録させる。事前配布不要で運用しやすい |
| **メールでのワンタイムパスワードを要求** | メールはデバイスに紐付かないため、業界標準の MFA としては弱い（補助的な選択肢） |
| **サインインをブロック** | MFA 未登録のユーザーは一切サインインさせない（最も厳格。事前に MFA 登録の導線を用意する必要あり） |
| **そのままサインインを許可** | MFA は任意。登録済みユーザーのみ MFA を求められる |

[05-セッション設定.md](./05-セッション設定.md) の 15 分セッションと組み合わせて厳格に運用するなら、**「MFAデバイスをサインイン時に登録させる」**（実用的）か **「サインインをブロック」**（最も厳格）を推奨する。

## 認証方式（Always On / Context-aware）

- **Always On**: 毎回のサインインで MFA を要求
- **Context-aware**: デバイス／ブラウザ／IP が変わったときだけ MFA を要求（「このデバイスを信頼する」を選ぶと以降スキップされる）

「サインインをブロック」設定と組み合わせる場合は **Always On** にしないと、Context-aware の「信頼済みデバイス」チェックで MFA がスキップされてしまう点に注意。

## ユーザー自身に MFA デバイスの追加・管理をさせる設定

「ユーザーが自分で MFA を設定できるようにしたい」という要件は、**Permission Set や IAM ポリシーでは実現できない**。MFA デバイスの登録・管理は AWS アクセスポータル（Identity Center サービスそのもの）の中で完結する操作であり、対象 AWS アカウントの IAM を一切経由しないため、IAM ポリシーの Action（`iam:EnableMFADevice` 等）を書いても効果がなく、対応する CloudFormation リソースも存在しない（コンソールのトグル操作のみ）。

設定場所は MFA デバイス強制設定と同じページ。

1. IAM Identity Center コンソール → **Settings** → **Authentication** タブ
2. **Multi-factor authentication** セクション → **Configure**
3. **Who can manage MFA devices** で以下のいずれかを選択
   - **Users can add and manage their own MFA devices**（ユーザー自身が追加・管理できる）
   - Only administrators can add and manage MFA devices for users（管理者のみが操作できる）
4. **Save changes**

ユーザーに自己管理させたい場合は前者を選択する。設定後、ユーザーへ [Registering your device for MFA](https://docs.aws.amazon.com/singlesignon/latest/userguide/user-device-registration.html) の手順を案内するとよい。

## サポートされる MFA デバイス

- 仮想認証アプリ（TOTP）: 1 ユーザーあたり最大 2 台
- FIDO 認証器（内蔵認証器／セキュリティキー）: 1 ユーザーあたり最大 6 台
- 合計で 1 ユーザーあたり最大 8 台まで登録可能

## 制約: グループ単位での MFA 強制はできない

この基本設定は **Identity Center インスタンス全体に一律適用**され、「Developers グループだけ任意、Infra グループは必須」のようなグループ単位の出し分けはできない。

グループごとに差をつけたい場合は、Permission Set 側のポリシーに `aws:MultiFactorAuthPresent` 条件キーを入れて、その Permission Set 経由のアクセスだけ MFA 必須にする、という応用テクニックが必要になる。

## 参考

- [Configure MFA device enforcement](https://docs.aws.amazon.com/singlesignon/latest/userguide/how-to-configure-mfa-device-enforcement.html)
- [MFA for Identity Center directory users](https://docs.aws.amazon.com/singlesignon/latest/userguide/enable-mfa.html)
- [Allow users to register their own MFA devices](https://docs.aws.amazon.com/singlesignon/latest/userguide/how-to-allow-user-registration.html)
