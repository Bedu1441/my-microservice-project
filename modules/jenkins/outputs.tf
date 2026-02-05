output "namespace" {
  value = var.namespace
}

output "release_name" {
  value = helm_release.jenkins.name
}

output "admin_password_command" {
  value = "kubectl -n ${var.namespace} get secret ${var.release_name} -o jsonpath=\"{.data.jenkins-admin-password}\" | % { [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_)) }"
}

output "service_command" {
  value = "kubectl -n ${var.namespace} get svc"
}
