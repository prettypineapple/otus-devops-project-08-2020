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

3) Helm

helm version
Client: &version.Version{SemVer:"v2.17.0", GitCommit:"a690bad98af45b015bd3da1a41f6218b1a451dbe", GitTreeState:"clean"}

3) kubectl

kubectl version
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:50:19Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}


Создание k8s кластера с Terraform:
 - gcloud auth login
 - gcloud config set project %PROJECT_ID%
 - gcloud services enable container.googleapis.com
 - cd /terraform/k8s-cluster
 - terraform init
 - terraform apply



 Поднятие системы мониторинга:
 - поднять кластер k8s

 - Получаем доступ в кластер
gcloud container clusters get-credentials %K8S_CLUSTER_NAME% --zone %ZONE% --project %PROJECT_ID% (команда копируется уже из самого gke)

 - Устанавливаем tiller в кластер:
cd kubernetes/Charts && kubectl apply -f tiller.yml

 - Запускаем tiller-сервер
helm init --service-account tiller

 - Ставим nginx
helm install stable/nginx-ingress --name nginx



# TODO: Этот шаг надо поправить на актуальный, пока тупо копипаста с ДЗ
 - С помощью команды "kubectl get svc" находим значение "EXTERNAL-IP" для "nginx-nginx-ingress-controller" и добавляем его в /etc/hosts
%NGINX_ERTERNAL_IP% reddit reddit-prometheus reddit-grafana reddit-non-prod production reddit-kibana staging prod

35.205.119.141 reddit reddit-prometheus reddit-grafana reddit-non-prod production reddit-kibana staging prod

# TODO: в настройках prometeus пока тупо копипаста с ДЗ

# TODO: Этот шаг надо поправить на актуальный, пока тупо копипаста с ДЗ. В частности не очень понимаю смысл upgrade prom
 - Ставим prometeus
cd prometheus && helm upgrade prom . -f custom_values.yml --install

Через некоторое время она будет доступна по ссылке http://reddit-prometheus/

 - Ставим графану
helm upgrade --install grafana stable/grafana --set "server.adminPassword=admin" \
--set "server.service.type=NodePort" \
--set "server.ingress.enabled=true" \
--set "server.ingress.hosts={reddit-grafana}"

Через некоторое время она будет доступна по ссылке http://reddit-grafana/

user: admin
pass: admin

# TODO: ну как и в ДЗ я встрял на какое-то говно..
default backend - 404

