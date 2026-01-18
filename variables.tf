variable "project_name" {
  type        = string
  description = "Project name prefix for resources"
}

variable "environment" {
  type        = string
  description = "Environment e.g., dev, qa, prod"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "azs" {
  type        = list(string)
  description = "Availability zones to use"
}

variable "cluster_name" {
  type        = string
  description = "EKS Cluster Name"
}

variable "eks_version" {
  type        = string
  default     = "1.28"
  description = "EKS Kubernetes version"
}
