terraform {
  backend "s3" {
    bucket         = "lesson7-terraform-state-428941813622"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lesson7-terraform-locks"
    encrypt        = true
  }
}
