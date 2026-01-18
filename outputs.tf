output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnet IDs"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnet IDs"
}

output "eks_cluster_name" {
  value       = module.eks.cluster_name
  description = "EKS Cluster Name"
}

output "s3_bucket_name" {
  value       = module.s3.bucket_name
  description = "S3 Bucket Name"
}

output "irsa_role_arn" {
  value       = module.s3.irsa_role_arn
  description = "IRSA IAM Role ARN"
}
