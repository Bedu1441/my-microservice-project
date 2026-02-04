terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10"
    }
  }
}

data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

locals {
  eks_host = data.aws_eks_cluster.this.endpoint
  eks_ca   = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
}

provider "kubernetes" {
  host                   = local.eks_host
  cluster_ca_certificate = local.eks_ca

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--region", "us-east-1", "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes = {
    host                   = local.eks_host
    cluster_ca_certificate = local.eks_ca

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--region", "us-east-1", "--cluster-name", module.eks.cluster_name]
    }
  }
}
