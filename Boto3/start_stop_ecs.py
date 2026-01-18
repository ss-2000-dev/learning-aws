import boto3

ecs = boto3.client('ecs')

def lambda_handler(event, context):
    # eventから 'start' か 'stop' を判定（Schedulerから渡す）
    action = event.get('action', 'stop')
    desired_count = 1 if action == 'start' else 0
    print(f"action: {action}")
    print(f"desired_count: {desired_count}")
    
    # 1. 全クラスターの取得
    paginator_cluster = ecs.get_paginator('list_clusters')
    print(f"--- paginator_cluster ---")
    print(paginator_cluster)

    for cluster_page in paginator_cluster.paginate():
        print(f"--- cluster_page ----")
        print(cluster_page)

        for cluster_arn in cluster_page['clusterArns']:
          # クラスター内の全サービスを取得
          paginator_service = ecs.get_paginator('list_services')
          print(f"--- paginator_service ---")
          print(paginator_service)

          for service_page in paginator_service.paginate(cluster=cluster_arn):
              print(f"--- service_page ---")
              print(service_page)
              
              for service_arn in service_page['serviceArns']:
                  # サービスの希望タスク数を更新
                  # Fargateはサービス単位での制御がベストプラクティス
                  ecs.update_service(
                      cluster=cluster_arn,
                      service=service_arn,
                      desiredCount=desired_count
                  )
                  
                  # 停止アクションの場合、実行中の全タスクを即時停止させる
                  if action == 'stop':
                      task_list = ecs.list_tasks(cluster=cluster_arn, serviceName=service_arn)
                      print(f"--- task_list ---")
                      print(task_list)
                      tasks = ecs.list_tasks(cluster=cluster_arn, serviceName=service_arn)['taskArns']
                      for task_arn in tasks:
                          ecs.stop_task(cluster=cluster_arn, task=task_arn, reason='Business Hours End')
    
    return {"status": "success", "action": action}