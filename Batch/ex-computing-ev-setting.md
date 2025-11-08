# ジョブとオーケストレーションタイプの設定

ex. EC2の場合
```
{
  "computeEnvironmentName": "getting-started-ec2-compute-env",
  "computeResources": {
    "type": "EC2",
    "instanceTypes": [
      "optimal"
    ],
    "minvCpus": 0,
    "desiredvCpus": 0,
    "maxvCpus": 256,
    "allocationStrategy": "BEST_FIT_PROGRESSIVE",
    "instanceRole": "arn:aws:iam::618584750402:instance-profile/ecsInstanceRole",
    "ec2Configuration": [],
    "launchTemplate": {},
    "subnets": [
      "subnet-05f128d6c01da9106",
      "subnet-049a2c6e93b8bc316",
      "subnet-0f9988d0eedf59ce8"
    ],
    "securityGroupIds": [
      "sg-08b0718e13d3803b6"
    ]
  },
  "serviceRole": null,
  "type": "MANAGED",
  "state": "ENABLED"
}
```

Fargateの場合
```
{
  "computeEnvironmentName": "getting-started-fargate-compute-env",
  "computeResources": {
    "type": "FARGATE",
    "maxvCpus": 256,
    "subnets": [
      "subnet-05f128d6c01da9106",
      "subnet-049a2c6e93b8bc316",
      "subnet-0f9988d0eedf59ce8"
    ],
    "securityGroupIds": [
      "sg-08b0718e13d3803b6"
    ]
  },
  "serviceRole": null,
  "type": "container",
  "state": "ENABLED"
}
```

