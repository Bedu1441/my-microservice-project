output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "argo_cd_namespace" {
  value = module.argo_cd.namespace
}

output "jenkins_namespace" {
  value = module.jenkins.namespace
}
