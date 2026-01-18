provider "aws" {
  region = var.aws_region
}

provider "tls" {
  # Used for OIDC provider thumbprint
}

variable "aws_region" {
  type        = string
  default     = "ap-south-1"
  description = "AWS Region"
}
