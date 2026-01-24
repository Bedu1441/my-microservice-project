output "bucket_name" {
  description = "Terraform state bucket name"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  description = "Terraform lock DynamoDB table name"
  value       = aws_dynamodb_table.terraform_locks.name
}
