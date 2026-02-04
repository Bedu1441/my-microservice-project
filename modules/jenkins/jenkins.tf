resource "kubernetes_namespace_v1" "jenkins" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_service_account_v1" "jenkins_agent" {
  metadata {
    name      = "jenkins-agent"
    namespace = kubernetes_namespace_v1.jenkins.metadata[0].name
  }
}

resource "helm_release" "jenkins" {
  name       = var.release_name
  namespace  = kubernetes_namespace_v1.jenkins.metadata[0].name
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  version    = var.chart_version

  values = [file("${path.module}/values.yaml")]

  set {
    name  = "controller.persistence.storageClass"
    value = "gp2"
  }

  set {
    name  = "controller.persistence.size"
    value = "8Gi"
  }

  timeout = 1800

  depends_on = [
    kubernetes_namespace_v1.jenkins,
    kubernetes_service_account_v1.jenkins_agent
  ]
}
