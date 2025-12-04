# ざっくりメモ

- ステートマシンと呼ばれる仕組みで設定や管理、自動化する
- AWS コンソールからワークフロー形式で可視化することができる
- 状態の遷移ごとに料金が発生、4000 回を超えると課金が発生
- グラフインスペクターで各ステップごとの実行結果を確認することができる
- ASL Amazon States Language と呼ばれる独自言語を用いて記述される（JSON ベースの構造化原語）
- [入門チュートリアル](https://docs.aws.amazon.com/step-functions/latest/dg/getting-started.html)

# 用語

- ステートマシン：StepFunctions における「ワークフロー設計図そのもの」、ワークフロー設計図のこと、ステートマシン = ワークフロー
- ステート：1 つ 1 つの処理単位、または制御単位、以下ステート例
  - Lambda を呼び出す
  - 条件分岐する
  - SNS に通知する
- ワークフロー
- Activity：Activity という機能を用いて、サーバーやコンテナ上に配置したアプリケーションを Step Functions から呼び出すこともできる

# ASL の解説

Step 1

```json
{
  "Comment": "テナント一覧を取得し、各テナントに対して外部サービスから顧客データを取得・保存するバッチ処理を行うステートマシン。エラー発生時はSNS通知＋FailStateでバッチを異常終了させる設計。",
  "StartAt": "SetBatchMeta",
  "States": {
    "SetBatchMeta": {
      "Type": "Pass",
      "Comment": "バッチ共通メタ情報（batchId、startTime、batchType）を作成する",
      "Parameters": {
        "batchId.$": "$$.Execution.Name",
        "startTime.$": "$$.Execution.StartTime",
        "batchType.$": "$$.StateMachine.Name"
      },
      "ResultPath": "$.meta",
      "Next": "LogBatchStart"
    },
    "LogBatchStart": {
      "Type": "Task",
      "Comment": "バッチ開始ログを出力する",
      "Resource": "arn:aws:lambda:ap-northeast-1:ACCOUNT_ID:function:BatchTenantSync_LogStartBatch",
      "Parameters": {
        "batchId.$": "$.meta.batchId",
        "startTime.$": "$.meta.startTime",
        "batchType.$": "$.meta.batchType"
      },
      "ResultPath": null,
      "Next": "LogBatchSuccess"
    },
    "LogBatchSuccess": {
      "Type": "Task",
      "Comment": "バッチ正常終了時にログを出力する",
      "Resource": "arn:aws:lambda:ap-northeast-1:ACCOUNT_ID:function:BatchTenantSync_LogEndBatch",
      "Parameters": {
        "batchId.$": "$.meta.batchId",
        "startTime.$": "$.meta.startTime",
        "batchType.$": "$.meta.batchType",
        "status": "SUCCEEDED"
      },
      "ResultPath": null,
      "Next": "SuccessState"
    },
    "SuccessState": {
      "Type": "Succeed",
      "Comment": "バッチ処理成功。正常終了する"
    }
  }
}
```

```json
{
  "Comment": "An example of the Amazon States Language using a choice state.",
  "StartAt": "FirstState",
  "States": {
    "FirstState": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:FUNCTION_NAME",
      "Next": "ChoiceState"
    },
    "ChoiceState": {
      "Type": "Choice",
      "Choices": [
        {
          "Variable": "$.foo",
          "NumericEquals": 1,
          "Next": "FirstMatchState"
        },
        {
          "Variable": "$.foo",
          "NumericEquals": 2,
          "Next": "SecondMatchState"
        }
      ],
      "Default": "DefaultState"
    },

    "FirstMatchState": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:OnFirstMatch",
      "Next": "NextState"
    },

    "SecondMatchState": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:OnSecondMatch",
      "Next": "NextState"
    },

    "DefaultState": {
      "Type": "Fail",
      "Error": "DefaultStateError",
      "Cause": "No Matches!"
    },

    "NextState": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:FUNCTION_NAME",
      "End": true
    }
  }
}
```

ステートマシン全体

- StartAt: このステートマシンの開始ステートを指定
- States: ステートの集合

ステート内

- Type：何をするステートなのかを指定
  - ex. Task, Pass, Choice, Wait, Map, Succeed, Fail
- Next：次のステートの指定
- Resouce：Task の場合利用するリソースを指定

#### メモ

- Map 　が少し複雑
- ステートの Input/Output のペイロードは、最大 256KB
  - 大きなデータをやり取りしたい場合は S3 か DynamoDB に保存して、キーのみをペイロードで受け渡しするのが回避策
- チュートリアル　 → 　ワークショップの順で学習するとよき

### 参考

- [AWS StepFunctions 入門](https://zenn.dev/yuyan/articles/8aa891b1b9d697) → 　すごくわかりやすかった
- [Amazon States Language（公式）](https://docs.aws.amazon.com/step-functions/latest/dg/concepts-amazon-states-language.html)
- [Workflow の状態（公式）](https://docs.aws.amazon.com/step-functions/latest/dg/workflow-states.html)
- [チュートリアル](https://docs.aws.amazon.com/step-functions/latest/dg/getting-started.html)
- [ワークショップ](https://catalog.workshops.aws/stepfunctions/en-US)
