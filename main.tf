############################
# Modules
############################

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  vpc_cidr     = var.vpc_cidr
  azs          = var.azs
}

module "eks" {
  source             = "./modules/eks"
  project_name       = var.project_name
  cluster_name       = var.cluster_name
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  public_subnet_ids  = module.vpc.public_subnet_ids
}

module "s3" {
  source                    = "./modules/s3"
  project_name              = var.project_name
  environment               = var.environment
  eks_oidc_provider_arn     = module.eks.oidc_provider_arn
  eks_oidc_provider_url     = module.eks.oidc_provider_url
  service_account_name      = "rbac-test-sa"
  service_account_namespace = "default"
}

module "docker" {
  source       = "./modules/docker"
  project_name = var.project_name
  environment  = var.environment
}

module "rbac" {
  source               = "./modules/rbac"
  project_name         = var.project_name
  environment          = var.environment
  cluster_name         = module.eks.cluster_name
  service_account_name = "rbac-test-sa"
  irsa_role_arn        = module.s3.irsa_role_arn
}

############################
# Kubernetes Provider
############################
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_ca_certificate)
  token                  = module.eks.cluster_auth_token
}

############################
# Test Pod Deployment
############################
resource "kubernetes_manifest" "test_pod" {
  manifest = yamldecode(
    templatefile("${path.module}/manifests/test_pod.yaml.tpl", {
      image_uri            = module.docker.docker_image_uri
      bucket_name          = module.s3.bucket_name
      service_account_name = "rbac-test-sa"
      namespace            = "default"
      environment          = var.environment
      cluster_name         = module.eks.cluster_name
    })
  )

  depends_on = [
    module.docker
  ]
}
