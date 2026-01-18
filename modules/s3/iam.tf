############################
# Locals
############################
locals {
  oidc_provider = replace(var.eks_oidc_provider_url, "https://", "")
}

############################
# IRSA IAM Role
############################
resource "aws_iam_role" "irsa_role" {
  name = "${var.project_name}-s3-irsa-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.eks_oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_provider}:aud" = "sts.amazonaws.com",
            "${local.oidc_provider}:sub" = "system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-s3-irsa-role"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

############################
# S3 Read/Write Policy
############################
resource "aws_iam_policy" "s3_rw_policy" {
  name        = "${var.project_name}-s3-rw-policy"
  description = "Read/Write access to S3 bucket via IRSA"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.this.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = "s3:ListBucket"
        Resource = aws_s3_bucket.this.arn
      }
    ]
  })
}

############################
# Attach Policy to Role
############################
resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.irsa_role.name
  policy_arn = aws_iam_policy.s3_rw_policy.arn
}
