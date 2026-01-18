output "docker_image_uri" {
  value       = "${aws_ecr_repository.test_pod.repository_url}:latest"
  description = "ECR Docker image URI for test pod"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.test_pod.repository_url
  description = "ECR Repository URL"
}

output "ecr_repository_name" {
  value       = aws_ecr_repository.test_pod.name
  description = "ECR Repository name"
}
