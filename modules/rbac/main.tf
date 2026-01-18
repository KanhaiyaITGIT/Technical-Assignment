##################################
# Kubernetes Provider (EKS)
##################################
data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.this.certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.this.token
}

##################################
# Namespaces
##################################
resource "kubernetes_namespace" "rbac_a" {
  metadata {
    name = "rbac-a"
    labels = {
      project     = var.project_name
      environment = var.environment
    }
  }
}

resource "kubernetes_namespace" "rbac_b" {
  metadata {
    name = "rbac-b"
    labels = {
      project     = var.project_name
      environment = var.environment
    }
  }
}

##################################
# Service Account
##################################
resource "kubernetes_service_account" "rbac_test_sa" {
  metadata {
    name      = var.service_account_name
    namespace = "default"
    labels = {
      app         = var.project_name
      environment = var.environment
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = var.irsa_role_arn
    }
  }
}

##################################
# ClusterRole for listing namespaces
##################################
resource "kubernetes_cluster_role" "list_namespaces" {
  metadata {
    name = "${var.project_name}-list-namespaces"
  }

  rule {
    api_groups = [""]
    resources  = ["namespaces"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "sa_list_ns" {
  metadata {
    name = "${var.project_name}-sa-list-namespaces-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rbac_test_sa.metadata[0].name
    namespace = kubernetes_service_account.rbac_test_sa.metadata[0].namespace
  }

  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.list_namespaces.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

##################################
# Roles for rbac-a (read-only)
##################################
resource "kubernetes_role" "rbac_a_role" {
  metadata {
    name      = "${var.project_name}-read-only"
    namespace = kubernetes_namespace.rbac_a.metadata[0].name
  }

  rule {
    api_groups = ["", "apps"]
    resources  = ["pods", "services", "deployments", "replicasets", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "rbac_a_binding" {
  metadata {
    name      = "${var.project_name}-read-only-binding"
    namespace = kubernetes_namespace.rbac_a.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rbac_test_sa.metadata[0].name
    namespace = kubernetes_service_account.rbac_test_sa.metadata[0].namespace
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.rbac_a_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

##################################
# Roles for rbac-b (full access)
##################################
resource "kubernetes_role" "rbac_b_role" {
  metadata {
    name      = "${var.project_name}-full-access"
    namespace = kubernetes_namespace.rbac_b.metadata[0].name
  }

  rule {
    api_groups = ["", "apps"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "rbac_b_binding" {
  metadata {
    name      = "${var.project_name}-full-access-binding"
    namespace = kubernetes_namespace.rbac_b.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.rbac_test_sa.metadata[0].name
    namespace = kubernetes_service_account.rbac_test_sa.metadata[0].namespace
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.rbac_b_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}
