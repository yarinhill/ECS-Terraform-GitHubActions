resource "aws_ecs_cluster" "ecs" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecs_service" "service" {
  name                    = "${var.project_name}-service"
  cluster                 = aws_ecs_cluster.ecs.id
  launch_type             = "FARGATE"
  enable_execute_command  = true
  desired_count           = 1
  task_definition         = aws_ecs_task_definition.td.arn
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = false 
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "${var.project_name}-app"
    container_port   = 3000
  }
  tags = {
    Name = "${var.project_name}-service"
  }
}

resource "aws_ecs_task_definition" "td" {
  container_definitions = jsonencode([
    {
      name         = "${var.project_name}-app"
      image        = aws_ecr_repository.repo.repository_url
      cpu          = 256
      memory       = 512
      essential    = true
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
  family                   = "${var.project_name}-app"
  requires_compatibilities = ["FARGATE"]
  cpu                = "256"
  memory             = "512"
  network_mode       = "awsvpc"
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
}

resource "local_file" "task_definition" {
  content  = jsonencode({
    family                   = aws_ecs_task_definition.td.family
    containerDefinitions     = jsondecode(aws_ecs_task_definition.td.container_definitions)
    cpu                      = aws_ecs_task_definition.td.cpu
    memory                   = aws_ecs_task_definition.td.memory
    networkMode              = aws_ecs_task_definition.td.network_mode 
    taskRoleArn              = aws_ecs_task_definition.td.task_role_arn
    executionRoleArn         = aws_ecs_task_definition.td.execution_role_arn
    requiresCompatibilities  = aws_ecs_task_definition.td.requires_compatibilities
  })
  filename = "../.github/workflows/ecs-task-definition.json"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn  = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
