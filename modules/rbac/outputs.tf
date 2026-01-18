output "namespace_a" {
  description = "Created Kubernetes namespace rbac-a"
  value       = kubernetes_namespace.rbac_a.metadata[0].name
}

output "namespace_b" {
  description = "Created Kubernetes namespace rbac-b"
  value       = kubernetes_namespace.rbac_b.metadata[0].name
}

output "service_account_name" {
  description = "Service account used for RBAC"
  value       = kubernetes_service_account.rbac_test_sa.metadata[0].name
}

output "rbac_a_role_name" {
  description = "RBAC-A read-only role name"
  value       = kubernetes_role.rbac_a_role.metadata[0].name
}

output "rbac_b_role_name" {
  description = "RBAC-B full access role name"
  value       = kubernetes_role.rbac_b_role.metadata[0].name
}
