terraform {
  required_version = ">= 1.5.0"
}

module "eks" {
  source = "./modules/eks"
}
