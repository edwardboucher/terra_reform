[
  {
    "name": "${app_name}",
    "image": "${repository_url}",
    "portMappings": [
      { "containerPort": 3000, "hostPort": 3000, "protocol": "tcp" },
      { "containerPort": 8080, "hostPort": 8080, "protocol": "tcp" },
      { "containerPort": 5900, "hostPort": 5900, "protocol": "tcp" },
      { "containerPort": 8501, "hostPort": 8501, "protocol": "tcp" },
      { "containerPort": 6080, "hostPort": 6080, "protocol": "tcp" }
    ],
    "environment": [
      { "name": "ANTHROPIC_API_KEY", "value": "${anthropic_api_key}" }
    ],
    "healthCheck": {
      "command": ["CMD-SHELL", "curl -f http://localhost:8080/ || exit 1"],
      "interval": 30,
      "timeout": 5,
      "retries": 3,
      "startPeriod": 60
    },
    "mountPoints": [
      {
        "sourceVolume": "efs-storage",
        "containerPath": "${efs_container_path}",
        "readOnly": false
      }
    ]
  }
]