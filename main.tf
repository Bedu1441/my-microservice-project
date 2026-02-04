terraform {
  required_version = ">= 1.5.0"
}

module "eks" {
  source = "./modules/eks"
}

module "argo_cd" {
  source       = "./modules/argo_cd"
  cluster_name = module.eks.cluster_name
  region       = "us-east-1"
}
