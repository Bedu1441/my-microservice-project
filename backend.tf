# Remote backend can be configured here (S3 + DynamoDB)
# For this project local state is used for simplicity.
#
# terraform {
#   backend "s3" {
#     bucket         = "example-terraform-states"
#     key            = "lesson-8-9/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "terraform-locks"
#     encrypt        = true
#   }
# }
