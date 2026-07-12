# サンプルシナリオ: IAM → IAM Identity Center 移行

[../03-移行手順.md](../03-移行手順.md) の一般的な手順を、具体的な題材に当てはめた実例。

## 前提シナリオ

- IAM グループは 2 つ: **Developers**（開発者グループ）、**Infra**（インフラグループ）
- **Developers**: AWS 管理ポリシー `PowerUserAccess` をアタッチ
- **Infra**: カスタムのインラインポリシー（EC2 / ELB / ASG / CloudFormation の操作は許可、IAM / Organizations の操作は明示的に拒否）をアタッチ
- グループ・ポリシーは CloudFormation で管理
- 管理する AWS アカウントは 1 つのみ

このシナリオには「AWS 管理ポリシーの移行」と「カスタムポリシーの移行」という 2 つの異なるパターンが含まれており、実際の移行作業で遭遇するケースの多くをカバーできる。

## 構成

| ファイル | 内容 |
|---|---|
| [before/iam-groups.yaml](./before/iam-groups.yaml) | 移行前（現状）の IAM グループ／ポリシーの CFN テンプレート |
| [after/identity-center-groups.yaml](./after/identity-center-groups.yaml) | 移行後の Identity Center グループ定義 |
| [after/identity-center-permission-sets.yaml](./after/identity-center-permission-sets.yaml) | 移行後の Permission Set 定義（旧ポリシーの移植方法を含む） |
| [after/identity-center-assignments.yaml](./after/identity-center-assignments.yaml) | 移行後の Account Assignment 定義 |
| [after/identity-center-all-in-one.yaml](./after/identity-center-all-in-one.yaml) | 上記3ファイル（Group / Permission Set / Assignment）を1つにまとめた版（テスト用）。同一スタック内なら `Outputs` + `Fn::ImportValue` を使わず `!GetAtt` / `!Ref` で直接参照できるため統合可能 |
| [移行手順.md](./移行手順.md) | 上記テンプレートを実際にデプロイする手順（コマンド例つき） |

## 対応表

| 移行前（IAM） | 移行後（Identity Center） | 移植方法 |
|---|---|---|
| `Developers` グループ + `PowerUserAccess`（AWS 管理ポリシー） | `DevelopersAccess` Permission Set | `ManagedPolicies` に同じ ARN を指定するだけ |
| `Infra` グループ + `InfraGroupCustomPolicy`（カスタムインラインポリシー） | `InfraAccess` Permission Set | `PolicyDocument` の中身をそのまま `InlinePolicy` にコピー |

> 本ドキュメント・テンプレート中のアカウント ID、Identity Store ID、インスタンス ARN はすべて説明用のダミー値。実際の値は各自の環境から取得すること。

## テンプレートの構文検証について（作業メモ）

`before/` `after/` の YAML テンプレート作成時、構文チェックのために以下を試した。

1. `python3 -c "import yaml"` → `pyyaml` 未導入のため失敗
2. `pip3 install --user pyyaml` を実行 → **失敗**（この Mac の Python 3.14 環境が壊れており `pyexpat` の `dlopen` に失敗するため、`pyyaml` は**インストールされていない**。`pip3 show pyyaml` で未検出であることを確認済み）
3. 代わりに **macOS 標準搭載の Ruby（`/usr/bin/ruby`、新規インストールなし）** の `Psych`（YAML パーサー）を使って構文チェックを実施した
   ```bash
   ruby -ryaml -e '
   Dir["before/*.yaml", "after/*.yaml"].each do |f|
     Psych.parse_stream(File.read(f))
     puts "#{f}: OK"
   end
   '
   ```

**結論: この作業で新規にインストールされたパッケージ・ツールは無い。** 元に戻す作業も不要。

もし将来 `pyyaml` のインストールを再試行して成功した場合、元に戻すには以下を実行する。

```bash
python3 -m pip uninstall pyyaml
```
