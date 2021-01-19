# otus-devops-project-08-2020
Репозиторий для выполнения проектной работы на курсе DevOps: Практики и инструменты

Пререквизиты:

1) gcloud

gcloud --version
Google Cloud SDK 303.0.0
alpha 2020.07.24
beta 2020.07.24
bq 2.0.58
core 2020.07.24
gsutil 4.52
kubectl 1.15.11

2) terraform

terraform -v
Terraform v0.12.29
+ provider.google v2.15.0


Создание k8s кластера с Terraform:
 - gcloud auth login
 - gcloud config set project PROJECT_ID
 - gcloud services enable container.googleapis.com
 - cd /terraform/k8s-cluster
 - terraform init
 - terraform apply