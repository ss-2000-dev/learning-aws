# IAM ユーザーを介さないアクセス

「IAM ユーザーではなく、完全にスイッチロールのみで開発・商用環境にアクセス・閲覧・操作するにはどうすればよいか」という疑問への回答。

## 結論: 今の設計はすでに「開発・商用に IAM ユーザーが存在しない」状態

[templates/switch-role-all-in-one.yaml](./templates/switch-role-all-in-one.yaml) の `IsTargetEnvironment` 側（Dev/Prod 用）を見ると、作っているのは `DevelopersRole` / `InfraRole` という**ロールだけ**で、`AWS::IAM::User` は一切ない。つまり最初から「Dev/Prod アカウントに IAM ユーザーというログイン手段自体が存在しない」設計になっている。IAM ユーザーがなければ、そのアカウントへの唯一の入口はスイッチロール（ロールの一時的な認証情報）しかない。

## チェックリスト: 何をすればこの状態を維持できるか

1. **Dev/Prod アカウントには絶対に IAM ユーザーを作らない**（運用ルールとして徹底する。今のテンプレートには最初から含まれていない）
2. **人間の実体（IAM ユーザー）はベースアカウント側だけに置く**。既にそうなっている（`DevelopersTestGroup` / `InfraTestGroup` はベースアカウント側）
3. **閲覧（読み取り専用の確認）もスイッチロール経由で行う**。「見るだけだから IAM ユーザーで直接ログイン」のような抜け道を作らない。ロールの切り替え後にコンソールを見るのも、CLI で `describe` 系コマンドを叩くのも同じ仕組みの上に乗っている

## 見落としがちな抜け穴: root ユーザー

**唯一「IAM ユーザーではないが直接ログインできてしまう存在」が、各アカウントの root ユーザー。** root は削除できず、スイッチロールを経由せず直接そのアカウントに万能アクセスできてしまう。「スイッチロールのみ」を徹底するなら、Dev/Prod それぞれの root に対して以下が必須。

- root の MFA を必ず有効化する
- root のアクセスキーは発行しない（発行済みなら削除する）
- root のパスワードは厳重に管理し、日常的には一切使わない（緊急時のみ）

## さらに強制力を持たせたい場合（2つの選択肢）

### 選択肢A: SCP で技術的に禁止する — ただし組織管理アカウントの権限が必要

AWS Organizations の **SCP（Service Control Policy）** で、「IAM ユーザーとしての操作を全面的に拒否する」ポリシーを Dev/Prod アカウントに割り当てれば、万一誰かが IAM ユーザーを作ってしまっても一切操作できなくなる。

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyDirectIamUserAccess",
      "Effect": "Deny",
      "Action": "*",
      "Resource": "*",
      "Condition": {
        "StringEquals": { "aws:PrincipalType": "IAMUser" }
      }
    }
  ]
}
```

**ただし、これは [../メモ.md](../メモ.md) で確認した「IAM Identity Center が却下された理由」と全く同じ壁にぶつかる。** SCP は Organizations の管理アカウント側でしか作成・アタッチできず、メンバーアカウント側の権限では設定できない。今回もこの手段は使えない可能性が高い。

### 選択肢B: 検知・通知で代替する — メンバーアカウントの権限だけで可能

管理アカウントの協力が得られない場合は、「事前に禁止する」代わりに「作られたら即座に気づく」検知型の対策に切り替える。これは Dev/Prod アカウント自身の権限だけで設定できる。

- CloudTrail で `iam:CreateUser` イベントを記録する（デフォルトで記録されている）
- EventBridge ルールで `iam:CreateUser` を検知し、SNS 通知や Lambda での自動削除をトリガーする

さらに、**今の `DevelopersRole` / `InfraRole` 自体には、そもそも `iam:CreateUser` を実行する権限がない**（`PowerUserAccess` は IAM 操作を除外、`InfraRole` は `iam:*` を明示的に Deny）。つまり日常的にスイッチロールで入ってくる人は、そもそも IAM ユーザーを作る権限自体を持っていない。抜け穴になり得るのは、アカウント作成時の `OrganizationAccountAccessRole` のような強力な管理者ロールと root だけ、というところまで既に絞り込まれている。

## まとめ

| 対象 | 状態 |
|---|---|
| Dev/Prod アカウントの IAM ユーザー | 最初から作らない（テンプレートにも含まれていない） |
| `DevelopersRole` / `InfraRole` | `iam:CreateUser` の権限自体を持たない（IAM ユーザーを自ら増やせない） |
| root ユーザー | 唯一の抜け穴。MFA 必須・アクセスキー発行禁止・日常利用禁止で対処 |
| SCP による強制禁止 | 組織管理アカウントの権限が必要（今回は利用不可の可能性が高い） |
| CloudTrail + EventBridge による検知 | メンバーアカウントの権限だけで設定可能な代替策 |
