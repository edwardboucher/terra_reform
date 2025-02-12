[
  {
    "name": "${app_name}",
    "image": "${repository_url}",
    "portMappings": [
      { "containerPort": ${container_port}, "hostPort": ${container_port}, "protocol": "tcp" }
    ],
    "environment": [
      { "name": "${container_env_name}", "value": "${container_env_vlue}" }
    ],
    "healthCheck": {
      "command": ["CMD-SHELL", "curl -f http://localhost:${container_port}/ || exit 1"],
      "interval": 30,
      "timeout": 5,
      "retries": 3,
      "startPeriod": 60
    },
    "mountPoints": [
      {
        "sourceVolume": "efs-storage",
        "containerPath": "/home/computeruse/.anthropic",
        "readOnly": false
      }
    ]
  }
]