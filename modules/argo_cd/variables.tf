variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "namespace" {
  type        = string
  description = "Namespace for Argo CD"
  default     = "argocd"
}

variable "chart_version" {
  type        = string
  description = "Helm chart version for argo-cd"
  default     = "7.6.12"
}

variable "release_name" {
  type        = string
  description = "Helm release name"
  default     = "argo-cd"
}
