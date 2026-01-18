AWSでのリソース起動・停止の自動化について、**最新のベストプラクティスである「Amazon EventBridge Scheduler」**を用いた手法を提案します。

従来の「EventBridge ルール」よりも、タイムゾーン指定（JST）が容易で、Lambdaを介さずにEC2やRDSのAPIを直接実行できるため、管理コストとエラーの発生率を抑えられます。

---

## 1. 全体構成のベストプラクティス

- EC2 / RDS: Lambdaを使わず、EventBridge SchedulerからAWS SDK API（Universal Target）を直接呼び出します。
- ECS Fargate: 「全タスクの停止」や「サービスの再起動」など複雑なロジックが必要なため、EventBridge SchedulerからLambdaを呼び出し、Python (Boto3) で制御します。

---

## 2. EC2 および RDS の自動起動・停止（直接連携）

EventBridge Schedulerの **Universal Target** 機能を使用すると、以下のメリットがあります。

- コード（Lambda）のメンテナンスが不要。
- Asia/Tokyo タイムゾーンで 09:00 / 18:00 を正確に指定可能。

### CloudFormation テンプレート（抜粋）

YAML```
Resources:
  # 1. Scheduler用IAMロール
  SchedulerRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Service: scheduler.amazonaws.com
            Action: sts:AssumeRole
      Policies:
        - PolicyName: StartStopPolicy
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: Allow
                Action:
                  - ec2:StartInstances
                  - ec2:StopInstances
                  - rds:StartDBInstance
                  - rds:StopDBInstance
                Resource: "*"

  # 2. EC2 起動スケジュール (平日 09:00 JST)
  EC2StartSchedule:
    Type: AWS::Scheduler::Schedule
    Properties:
      Name: EC2-Start-Schedule
      ScheduleExpression: "cron(0 9 ? * MON-FRI *)"
      ScheduleExpressionTimezone: "Asia/Tokyo"
      FlexibleTimeWindow:
        Mode: "OFF"
      Target:
        Arn: "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
        RoleArn: !GetAtt SchedulerRole.Arn
        Input: '{"InstanceIds": ["i-xxxxxxxxxxxxxxxxx"]}'

  # 3. RDS 停止スケジュール (平日 18:00 JST)
  RDSStopSchedule:
    Type: AWS::Scheduler::Schedule
    Properties:
      Name: RDS-Stop-Schedule
      ScheduleExpression: "cron(0 18 ? * MON-FRI *)"
      ScheduleExpressionTimezone: "Asia/Tokyo"
      FlexibleTimeWindow:
        Mode: "OFF"
      Target:
        Arn: "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
        RoleArn: !GetAtt SchedulerRole.Arn
        Input: '{"DbInstanceIdentifier": "my-db-instance"}'

```

---

## 3. ECS Fargate の自動起動・停止（Lambda経由）

Fargateにおいて「停止」とは、**サービスの「希望するタスク数 (Desired Count)」を 0 にすること**を指します。単にタスクを `stop_task` で終了させると、サービスが新しいタスクを自動で起動してしまうためです。

### Python サンプルコード (Lambda用)

このスクリプトは、全クラスター内の全サービスの希望するタスク数を変更します。

Python```
import boto3
import os

ecs = boto3.client('ecs')

def lambda_handler(event, context):
    # eventから 'start' か 'stop' を判定（Schedulerから渡す）
    action = event.get('action', 'stop')
    desired_count = 1 if action == 'start' else 0
    
    # 1. 全クラスターの取得
    clusters = ecs.list_clusters()['clusterArns']
    
    for cluster_arn in clusters:
        # 2. クラスター内の全サービスの取得
        services = ecs.list_services(clusterArn=cluster_arn)['serviceArns']
        
        for service_arn in services:
            print(f"Updating service {service_arn} to desired count {desired_count}")
            # 3. サービスを更新（起動/停止）
            ecs.update_service(
                cluster=cluster_arn,
                service=service_arn,
                desiredCount=desired_count
            )
            
            # 停止時のみ：実行中の個別タスクを強制終了したい場合（追加要件用）
            if action == 'stop':
                tasks = ecs.list_tasks(cluster=cluster_arn, serviceName=service_arn)['taskArns']
                for task_arn in tasks:
                    ecs.stop_task(cluster=cluster_arn, task=task_arn, reason='Scheduled stop')

    return {"status": "success", "action": action}

```

### CloudFormation テンプレート（ECS用）

YAML```
Resources:
  # Lambda 実行ロール
  LambdaExecutionRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: "2012-10-17"
        Statement:
          - Effect: Allow
            Principal:
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
      ManagedPolicyArns:
        - arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
      Policies:
        - PolicyName: ECSPolicy
          PolicyDocument:
            Version: "2012-10-17"
            Statement:
              - Effect: Allow
                Action:
                  - ecs:ListClusters
                  - ecs:ListServices
                  - ecs:UpdateService
                  - ecs:ListTasks
                  - ecs:StopTask
                Resource: "*"

  # ECS制御用 Lambda
  ECSControlFunction:
    Type: AWS::Lambda::Function
    Properties:
      Handler: index.lambda_handler
      Role: !GetAtt LambdaExecutionRole.Arn
      Runtime: python3.11
      Code:
        ZipFile: |
          # (上記Pythonコードをここに貼り付け)

  # ECS停止スケジュール
  ECSStopSchedule:
    Type: AWS::Scheduler::Schedule
    Properties:
      Name: ECS-Stop-Schedule
      ScheduleExpression: "cron(0 18 ? * MON-FRI *)"
      ScheduleExpressionTimezone: "Asia/Tokyo"
      FlexibleTimeWindow: { Mode: "OFF" }
      Target:
        Arn: !GetAtt ECSControlFunction.Arn
        RoleArn: !GetAtt SchedulerRole.Arn # 前述のロール
        Input: '{"action": "stop"}'

```

---

## 4. 参考ドキュメント

実装の詳細は以下の公式リファレンスに基づいています。

- AWS CLI Reference (Scheduler): create-scheduleScheduleExpressionTimezone を "Asia/Tokyo" に設定する方法。
- Boto3 SDK Reference (ECS):list_clustersupdate_service
- Amazon EventBridge Scheduler Universal Targets: Managing schedulesAPIを直接呼び出す際の arn:aws:scheduler:::aws-sdk:サービス名:アクション名 の形式。

## 次のステップへの提案

特定のEC2やRDSだけに絞って起動・停止したい場合は、CloudFormationの **Parameters** セクションで `InstanceId` などを定義するか、特定のリソースタグ（例：`Schedule: BusinessHours`）が付いたものだけをLambdaで抽出する構成に変更可能です。

特定のタグが付いたリソースのみを対象にするLambdaコードの作成もお手伝いしましょうか？