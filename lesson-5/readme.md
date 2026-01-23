# Lesson 5 — Terraform IaC (AWS)

Region: **us-east-1**

This project provisions AWS infrastructure using Terraform modules:
- Remote state backend: **S3 + DynamoDB locking**
- Network: **VPC** with **3 public** and **3 private** subnets
- Container registry: **ECR** repository (scan on push)

---

## Project structure

lesson-5/
├── main.tf
├── backend.tf
├── outputs.tf
├── README.md
│
├── modules/
│ ├── s3-backend/
│ │ ├── s3.tf
│ │ ├── dynamodb.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ │
│ ├── vpc/
│ │ ├── vpc.tf
│ │ ├── routes.tf
│ │ ├── variables.tf
│ │ └── outputs.tf
│ │
│ └── ecr/
│ ├── ecr.tf
│ ├── variables.tf
│ └── outputs.tf


---

## Prerequisites

- AWS CLI configured with IAM user (not root)
- Terraform installed
- AWS region set to **us-east-1**

Check:
```bash
aws sts get-caller-identity
aws configure get region
terraform -v


How to run
1) Initialize
terraform init

2) Plan
terraform plan

3) Apply
terraform apply

4) Outputs
terraform output

5) Destroy (IMPORTANT)

After review, remove all resources to avoid costs:

terraform destroy

Modules explanation
Module: s3-backend

Creates:

S3 bucket for Terraform state (versioning enabled)

DynamoDB table for state locking

Outputs:

S3 bucket name

DynamoDB table name

Module: vpc

Creates:

VPC (CIDR 10.0.0.0/16)

3 public subnets + 3 private subnets

Internet Gateway

Route tables and associations

Outputs:

VPC ID

Public subnet IDs

Private subnet IDs

Module: ecr

Creates:

ECR repository with scan on push enabled

Outputs repository URL

Notes about costs

NAT Gateway / networking resources may generate charges.
Always run terraform destroy after verification.
