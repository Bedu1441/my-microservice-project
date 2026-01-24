# Lesson 7 — Kubernetes on AWS (EKS) with Terraform, ECR and Helm

## Overview

This project demonstrates a complete workflow of deploying a containerized Django application to **Amazon EKS** using **Terraform**, **Amazon ECR**, and **Helm**.

The solution includes:
- Infrastructure provisioning with Terraform
- Docker image build and push to ECR
- Application deployment via Helm
- Autoscaling with HPA
- Configuration management with ConfigMap

---

##nfrastructure (Terraform)

The following AWS resources are provisioned using Terraform:

- **S3 + DynamoDB** — Terraform backend and state locking
- **VPC** with public subnets
- **ECR repository** for Docker images
- **EKS cluster**
- **EKS managed node group**

### Apply infrastructure
```bash
terraform init
terraform apply
Verify cluster
kubectl get nodes

Docker & Amazon ECR
Build and push Docker image
export ECR_URL=428941813622.dkr.ecr.us-east-1.amazonaws.com/lesson-7-django-app

aws ecr get-login-password --region us-east-1 \
 | docker login --username AWS --password-stdin $ECR_URL

docker buildx build \
  --platform linux/amd64 \
  -t $ECR_URL:latest \
  --push .
Verify image in ECR
aws ecr list-images \
  --repository-name lesson-7-django-app \
  --region us-east-1

Kubernetes Deployment (Helm)
The application is deployed using a custom Helm chart.

Helm resources
Deployment

Service (LoadBalancer)

HorizontalPodAutoscaler (HPA)

ConfigMap

Install / upgrade release
helm upgrade --install django charts/django-app

Verification
Deployment
kubectl get deploy
Service
kubectl get svc
HPA
kubectl get hpa

onfigMap Usage
The application configuration is stored in a ConfigMap and injected into the container via envFrom.

Proof of ConfigMap usage
kubectl get deploy django-app -o yaml | grep -A5 -B5 configMap
Example:

envFrom:
  - configMapRef:
      name: django-app-config

Repository Structure
.
├── charts/
│   └── django-app/
├── modules/
│   ├── ecr/
│   ├── eks/
│   ├── s3-backend/
│   └── vpc/
├── lesson-7/
│   └── terraform files
├── Dockerfile
├── requirements.txt
└── README.md

Result
The Django application is successfully running on AWS EKS with:
automated infrastructure provisioning,
container image management,
scalable Kubernetes deployment,
and externalized configuration.

