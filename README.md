# Мій власний мікросервісний проєкт  

# CI/CD пайплайн з Jenkins, Kaniko, AWS ECR, Helm та Argo CD

Цей проєкт демонструє повноцінний CI/CD та GitOps workflow для Kubernetes із використанням Jenkins, Kaniko, Amazon ECR, Helm, Terraform та Argo CD.

Пайплайн автоматично:
- збирає Docker-образи,
- публікує їх у Amazon ECR,
- оновлює Helm-конфігурацію в окремому Git-репозиторії,
- розгортає зміни в Kubernetes через Argo CD (auto-sync).


## Загальна архітектура

Логіка роботи системи:

1. Terraform
   - створює EKS-кластер
   - встановлює Jenkins та Argo CD через Helm

2. Jenkins Pipeline
   - запускається в Kubernetes (dynamic agents)
   - збирає Docker-образ за допомогою Kaniko
   - пушить образ у Amazon ECR
   - оновлює тег образу в Helm-репозиторії

3. Argo CD (GitOps)
   - слідкує за Helm-репозиторієм
   - автоматично застосовує зміни в Kubernetes

Developer → Git push → Jenkins → ECR → Helm repo → Argo CD → Kubernetes


## Структура репозиторію
.
├── Dockerfile
├── Jenkinsfile
├── modules/
│ ├── eks/
│ ├── jenkins/
│ └── argo_cd/
├── terraform/
│ ├── backend.tf
│ ├── providers.tf
│ ├── main.tf
│ └── variables.tf
├── k8s_providers.tf
├── outputs.tf
└── README.md


## Передумови (Prerequisites)

- AWS акаунт
- IAM користувач з правами:
  - EKS
  - ECR
  - EC2
  - IAM
- Локально встановлено:
  - Terraform ≥ 1.5
  - kubectl
  - AWS CLI
- GitHub Personal Access Token (PAT)

Використання DynamoDB у проєкті - Amazon DynamoDB не використовується як база даних застосунку. Згадується та може застосовуватися виключно для Terraform state locking у випадку використання remote backend з Amazon S3. Це дозволяє запобігти одночасному виконанню terraform apply та пошкодженню state-файлу в командному середовищі. У рамках проєкту: Terraform state може зберігатися локально або в S3 без блокування; DynamoDB не є обовʼязковим компонентом для роботи CI/CD pipeline; Jenkins, Argo CD та GitOps workflow не залежать від DynamoDB.
За необхідності проєкт розширюється використанням DynamoDB для Terraform state locking.

## Розгортання інфраструктури

### 1. Налаштування AWS credentials

```bash
aws configure
Перевірка доступу:

aws sts get-caller-identity
2. Ініціалізація Terraform
terraform init
3. Створення інфраструктури terraform apply
У результаті буде:
створений або налаштований EKS
встановлений Jenkins
встановлений Argo CD
Налаштування Credentials у Jenkins

У Jenkins → Manage Credentials необхідно додати:

1. GitHub PAT
Тип: Secret text

ID: github-pat

Значення: GitHub Personal Access Token

2. AWS credentials для ECR
Тип: Username with password

ID: aws-ecr

Username: aws

Password: AWS_SECRET_ACCESS_KEY

AWS_ACCESS_KEY_ID використовується як username змінна

Jenkins Pipeline
Пайплайн виконує такі кроки:

Checkout основного репозиторію

Збірка Docker-образу через Kaniko

Публікація образу в Amazon ECR

Клонування Helm Git-репозиторію

Оновлення image tag у values.yaml

Commit та push змін у main гілку

Особливості:
без Docker daemon
повністю в Kubernetes
безпечна робота з credentials
сумісність з GitOps

Збірка Docker-образу
Збірка виконується за допомогою Kaniko

Dockerfile знаходиться в корені проєкту

Теги образів:

<short_commit_sha>-<build_number>

latest

GitOps деплой через Argo CD
Argo CD відстежує Helm-репозиторій

Будь-яка зміна values.yaml викликає auto-sync

Деплой у Kubernetes відбувається автоматично

Стан Argo CD Application:

Synced

Healthy

Перевірка працездатності
 Jenkins pipeline завершився зі статусом SUCCESS
 Docker-образ зʼявився в Amazon ECR
 Helm values оновлено новим тегом
 Argo CD автоматично застосував зміни
 Kubernetes deployment оновлено

Продемонстровані DevOps практики
Jenkins у Kubernetes
Kaniko (daemonless Docker build)
AWS ECR authentication
GitHub Personal Access Token
Helm-деплой
GitOps з Argo CD
Infrastructure as Code (Terraform)

Висновок
Проєкт реалізує сучасний CI/CD пайплайн із GitOps-підходом, який відповідає production-рівню розгортання Kubernetes-застосунків та демонструє повний DevOps lifecycle.
