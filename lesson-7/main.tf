provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

module "s3_backend" {
  source = "./modules/s3-backend"

  bucket_name          = "lesson7-terraform-state-${data.aws_caller_identity.current.account_id}"
  dynamodb_table_name  = "lesson7-terraform-locks"
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = "lesson-7-django-app"
}

module "vpc" {
  source = "./modules/vpc"

  name           = "lesson-7-vpc"
  cidr_block     = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  azs            = ["us-east-1a", "us-east-1b"]
}

module "eks" {
  source = "./modules/eks"

  cluster_name = "lesson-7-eks"
  region       = "us-east-1"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  node_instance_types = ["t3.micro"]
  desired_size = 2
  min_size     = 2
  max_size     = 6
}
