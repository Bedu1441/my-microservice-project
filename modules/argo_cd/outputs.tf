output "namespace" {
  value = var.namespace
}

output "release_name" {
  value = helm_release.argocd.name
}

output "login_username" {
  value = "admin"
}

output "admin_password_command" {
  value = "kubectl -n ${var.namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode"
}
