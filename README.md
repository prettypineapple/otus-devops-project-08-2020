# otus-devops-project-08-2020

Репозиторий для выполнения проектной работы на курсе DevOps: Практики и инструменты

## Пререквизиты

### gcloud

```
gcloud --version
Google Cloud SDK 303.0.0
alpha 2020.07.24
beta 2020.07.24
bq 2.0.58
core 2020.07.24
gsutil 4.52
kubectl 1.15.11
```

### terraform

```
terraform -v
Terraform v0.12.29
+ provider.google v2.15.0
```

### Helm

```
helm version
Client: &version.Version{SemVer:"v2.17.0", GitCommit:"a690bad98af45b015bd3da1a41f6218b1a451dbe", GitTreeState:"clean"}
```

### kubectl

```
kubectl version
Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", GitCommit:"1e11e4a2108024935ecfcb2912226cedeafd99df", GitTreeState:"clean", BuildDate:"2020-10-14T12:50:19Z", GoVersion:"go1.15.2", Compiler:"gc", Platform:"linux/amd64"}
```

### docker

docker version
```
Client: Docker Engine - Community
 Version:           19.03.12
 API version:       1.40
 Go version:        go1.13.10
 Git commit:        48a66213fe
 Built:             Mon Jun 22 15:45:44 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.12
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.13.10
  Git commit:       48a66213fe
  Built:            Mon Jun 22 15:44:15 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

## 1. Создание k8s кластера с Terraform

- `gcloud auth login`
- `gcloud config set project %PROJECT_ID%`
- `gcloud services enable container.googleapis.com`
- `cd terraform/k8s-cluster`
- `terraform init`
- `terraform apply`

### Поднятие системы мониторинга

- TODO: поднять кластер k8s

### Получаем доступ в кластер

`gcloud container clusters get-credentials %K8S_CLUSTER_NAME% --zone %ZONE% --project %PROJECT_ID%`
(команда копируется уже из самого gke)

### Устанавливаем tiller в кластер

`cd kubernetes/Charts && kubectl apply -f tiller.yml`

### Запускаем tiller-сервер

`helm init --service-account tiller`

### Ставим nginx

`helm install stable/nginx-ingress --name nginx`

#### TODO: Этот шаг надо поправить на актуальный, пока тупо копипаста с ДЗ

С помощью команды `kubectl get svc` находим значение `EXTERNAL-IP` для `nginx-nginx-ingress-controller` и добавляем его в `/etc/hosts`

`%NGINX_ERTERNAL_IP% reddit reddit-prometheus reddit-grafana reddit-non-prod production reddit-kibana staging prod`

`35.205.119.141 reddit reddit-prometheus reddit-grafana reddit-non-prod production reddit-kibana staging prod`

## 2. Настройка мониторинга

#### TODO: в настройках prometeus пока тупо копипаста с ДЗ

#### TODO: Этот шаг надо поправить на актуальный, пока тупо копипаста с ДЗ. В частности не очень понимаю смысл upgrade prom

### Устанавливаем prometeus

`cd prometheus && helm upgrade prom . -f custom_values.yml --install`

Через некоторое время она будет доступна по ссылке http://reddit-prometheus/

### Устанавливаем grafana

```
helm upgrade --install grafana stable/grafana --set "server.adminPassword=admin" \
--set "server.service.type=NodePort" \
--set "server.ingress.enabled=true" \
--set "server.ingress.hosts={reddit-grafana}"
```

Через некоторое время она будет доступна по ссылке http://reddit-grafana/

user: admin
pass: admin

#### TODO: ну как и в ДЗ я встрял на какое-то говно.

default backend - 404

## 3. Запуск приложения

### Сборка докер образов с приложениями

```
cd Dockers/search_engine_ui && docker build -t funnyfatty/search_ui:1.0 . && cd ../search_engine_crawler && docker build -t funnyfatty/search_crawler:1.0 .
```

Также запушим в наш репо (иначе в кубере не взлетит):
`docker push funnyfatty/search_ui:1.0 && docker push funnyfatty/search_crawler:1.0`

## 3.1. Запуск приложения (non k8s)

1) Создаём сетку
`docker network create local_docker --driver bridge`

2) Запуск rabbitmq
`docker run -d --hostname rabbitmq --name rabbitmq-name --network=local_docker --network-alias=rabbitmq -e RABBITMQ_DEFAULT_USER=user -e RABBITMQ_DEFAULT_PASS=password rabbitmq:3-management`

3) Запуск mongodb
`docker run -d --hostname mongodb --name mongodb-name --network=local_docker --network-alias=mongodb mongo:4.4.3`

4)Запускаем сервисы
`docker run -d --hostname search_crawler --name search_crawler-name --network=local_docker --network-alias=search_crawler funnyfatty/search_crawler:1.0`
`docker run -d --hostname search_ui --name search_ui-name --network=local_docker --network-alias=search_ui -p 8000:8000 funnyfatty/search_ui:1.0`

Если открывается `http://localhost:8000/` - это знак хороший.

## 3.2. Поднимаем приложения в k8s (с kubectl)

1. `cd kubernetes/Apps`
  1.1. Если ранее не подключались к кластеру - `gcloud container clusters get-credentials %K8S_CLUSTER_NAME% --zone %ZONE% --project %PROJECT_ID%` (команда копируется уже из самого gke)
2. `kubectl apply -f .`
3. `kubectl get ingress`
Ищем IP ingress'a (он также нужен для генерации сертификата)
4. Ждём около 3-5 минут пока раздуплиться UI
5. `http://ingress_ip` -> профит

### Настройка HTTPS

1. Раcкомментируем строчки для `ui-ingress.yml`
2. Генерируем сертификат для https
`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=34.117.102.70"`
3. Копируем его в кластер
`kubectl create secret tls ui-ingress --key tls.key --cert tls.crt`
4. `kubectl apply -f ui-ingress.yml`
5. `https://ingress_ip` -> профит

## 3.3. Поднимаем приложение с помощью helm (нужен tiller)

`cd kubernetes/Charts/search-engine-app && helm dep update && cd .. && helm install search-engine-app --name app-test`

## 4. Создание pipeline для непрерывного тестирования и раскатки новых релизов

## 4.1 Установка и запуск Gitlab-CI

1. Создаём новую VM в GCP: 1 vCPU, 3.75 GB memory, 100 GB persistent disk, Ubuntu 16.04 LTS;
2. Добавляем ssh-ключ для пользователя и заходим по ssh;
3. Выполняем с правами пользователя `root` установку `docker` и `docker-compose`:

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-compose
```

4. Подготавливаем необходимые директории и создаём `docker-compose.yml`:

```
mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
cd /srv/gitlab/
touch docker-compose.yml
```

5. Копируем в `docker-compose.yml` содержимое `gitlab-ci/docker-compose.yml` и выполняем команду `docker-compose up -d`;
6. После того, как Gilab-CI запустится по адресу `http://gitlab-vm-ip`, устанавливаем пароль для пользователя `root` и выключаем в настройках возможность регистрации.

## 4.2 Создание проекта и gitlab-runner

1. Создаём новый проект в Gitlab-CI;
2. Запускаем на машине с развёрнутым Gitlab-CI gitlab-runner:

```
sudo docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```

3. Регистрируем gitlab-runner для проекта:

```
sudo docker exec -it gitlab-runner gitlab-runner register -n \
  --url http://gitlab-vm-ip/ \
  --registration-token <TOKEN> \
  --executor docker \
  --description "My Docker Runner" \
  --docker-image "docker:19.03.12" \
  --docker-volumes /var/run/docker.sock:/var/run/docker.sock
```

4. В локальном git-репозитории подключаем upstream и загружаем содержимое репозитория в Gitlab-CI:

```
git checkout -b gitlab-ci
git remote add gitlab http://34.89.244.97/otus-project/diploma
git push gitlab gitlab-ci
```

## 4.3 Описание pipeline и тестирование приложения

Описание pipeline находится в файле `.gitlab-ci.yml` в корне репозитория.
На 26.01 реализована автоматизированная сборка образов и запуск тестов.

#### TO DO: автоматизированная выкатка приложения в k8s

В данный момент Gitlab-CI и pipeline для текущего проекта доступен по ссылке: http://34.89.244.97/otus-project/diploma

