output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "cluster_auth_token" {
  value       = data.aws_eks_cluster_auth.this.token
  sensitive   = true
  description = "EKS cluster auth token"
}

output "node_group_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "oidc_provider_arn" {
  value       = aws_iam_openid_connect_provider.eks.arn
  description = "EKS OIDC Provider ARN for IRSA"
}

output "oidc_provider_url" {
  value       = aws_iam_openid_connect_provider.eks.url
  description = "EKS OIDC Provider URL"
}
