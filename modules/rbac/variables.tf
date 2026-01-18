############################
# Common
############################
variable "project_name" {
  description = "Project name for naming resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev / stage / prod)"
  type        = string
}

############################
# Kubernetes Access
############################
variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for RBAC"
  type        = string
  default     = "default"
}

############################
# Service Account
############################
variable "service_account_name" {
  description = "Kubernetes Service Account name"
  type        = string
}

variable "irsa_role_arn" {
  description = "IRSA IAM Role ARN for service account annotations"
  type        = string
}
