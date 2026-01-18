############################
# Docker Module Variables
############################
variable "project_name" {
  description = "Project name for ECR repository naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/stage/prod)"
  type        = string
}
