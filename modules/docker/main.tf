############################
# ECR Repository
############################
resource "aws_ecr_repository" "test_pod" {
  name                 = "${var.project_name}-test-pod"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.project_name}-test-pod"
    Environment = var.environment
  }
}

############################
# Docker Build and Push
############################
resource "null_resource" "docker_build_push" {
  triggers = {
    repo = aws_ecr_repository.test_pod.repository_url
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "Logging in to ECR..."
      aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${aws_ecr_repository.test_pod.repository_url}

      echo "Building Docker image..."
      docker build -t test-pod:latest "${path.module}/../docker"

      echo "Tagging image..."
      docker tag test-pod:latest ${aws_ecr_repository.test_pod.repository_url}:latest

      echo "Pushing to ECR..."
      docker push ${aws_ecr_repository.test_pod.repository_url}:latest
    EOT
  }
}

############################
# Data Source
############################
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

