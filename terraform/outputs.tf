output "aws_region" {
  description = "The AWS region"
  value       = var.region_master
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.ecs.name
}

output "container_name" {
  description = "The name of the Container"
  value = "${var.project_name}-app"
}

output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.service.name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.repo.repository_url
}

output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.repo.name
}

output "ALB-DNS-NAME" {
  description = "The DNS of the ALB"
  value = aws_lb.app_alb.dns_name
}