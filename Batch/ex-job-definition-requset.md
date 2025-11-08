# ジョブ定義リクエスJSON

ex. EC2の場合
```
{
  "jobDefinitionName": "getting-started-ec2-job-definition",
  "containerProperties": {
    "command": [
      "echo",
      "hello world"
    ],
    "image": "public.ecr.aws/amazonlinux/amazonlinux:latest",
    "resourceRequirements": [
      {
        "type": "VCPU",
        "value": "1"
      },
      {
        "type": "MEMORY",
        "value": "2048"
      }
    ],
    "secrets": [],
    "environment": [],
    "linuxParameters": {
      "tmpfs": [],
      "devices": []
    },
    "ulimits": []
  },
  "platformCapabilities": [
    "EC2"
  ],
  "type": "container",
  "propagateTags": null,
  "tags": null
}
```

ex. Fargateの場合
```
{
  "jobDefinitionName": "getting-started-fargate-job-definition",
  "type": "container",
  "containerProperties": {
    "image": "public.ecr.aws/amazonlinux/amazonlinux:latest",
    "command": [
      "echo",
      "hello world"
    ],
    "resourceRequirements": [
      {
        "type": "VCPU",
        "value": "1"
      },
      {
        "type": "MEMORY",
        "value": "2048"
      }
    ],
    "fargatePlatformConfiguration": {
      "platformVersion": "LATEST"
    },
    "networkConfiguration": {
      "assignPublicIp": "ENABLED"
    },
    "runtimePlatform": {
      "cpuArchitecture": "X86_64",
      "operatingSystemFamily": "LINUX"
    },
    "ephemeralStorage": {},
    "executionRoleArn": "arn:aws:iam::618584750402:role/ecsTaskExecutionRole",
    "environment": []
  },
  "platformCapabilities": [
    "FARGATE"
  ],
  "propagateTags": null,
  "tags": null
}
```
