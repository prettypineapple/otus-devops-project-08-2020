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

## Как установить почти всё почти в один клик:
`sh install_all.sh`
Далее  выполняем настройку из `2.1 Настройка мониторинга` и переходим к `## 4. Создание pipeline для непрерывного тестирования и раскатки новых релизов`

## 1. Создание k8s кластера с Terraform и настройка cmd для работы с ним

- `gcloud auth login`
- `gcloud config set project %PROJECT_ID%`
- `gcloud services enable container.googleapis.com`
- `cd terraform/k8s-cluster`
- `terraform init`
- `terraform apply -auto-approve`
- `gcloud container clusters get-credentials gke-cluster --zone europe-west1-b --project diploma-301517`
- `cd ../../kubernetes/Charts && kubectl apply -f tiller.yml`
- `helm init --service-account tiller`


## 2. Поднятие системы мониторинга

- `cd kubernetes/Charts/prometheus && helm dep update && cd .. && helm install prometheus --name monitoring-system` (Вместе с prometheus будет развёрнут nginx и графата)
- С помощью команды `kubectl get svc` находим значение `EXTERNAL-IP` для `monitoring-system-nginx-ingress-controller` и добавляем в `/etc/hosts` строку `appsec-prometheus appsec-grafana search-engine production staging prod`
- Через некоторое время он будет доступен по ссылке http://appsec-prometheus/, а также будет доступна графана http://appsec-grafana/ (admin:admin)


## 2.1 Настройка мониторинга
- Добавляем prometheus data-source (шестерёнка -> Data Sources -> Add Data Source -> Prometheus)
- URL: `http://monitoring-system-prometheus-server` -> save and test -> Back (он будет сохранён)
- Добавляем `Kubernetes cluster monitoring (via Prometheus)` плагин. (4 квадратика -> Manage -> import -> Upload JSON file -> Выбрать kubernetes/Charts/grafana/kubernetes-cluster-monitoring-via-prometheus_rev3.json -> Выбираем наш prometheus -> import -> profit)

## 3. Сборка и запуск приложения (ручные)

### Сборка докер образов с приложениями

```
cd Dockers/search_engine_ui && docker build -t %GITHUBUSER%/search_ui:1.0 . && cd ../search_engine_crawler && docker build -t %GITHUBUSER%/search_crawler:1.0 .
```

Также запушим в наш репо (иначе в кубере не взлетит):
`docker push %GITHUBUSER%/search_ui:1.0 && docker push %GITHUBUSER%/search_crawler:1.0`

## 3.1. Запуск приложения (non k8s)

1) Создаём сетку
`docker network create local_docker --driver bridge`

2) Запуск rabbitmq
`docker run -d --hostname rabbitmq --name rabbitmq-name --network=local_docker --network-alias=rabbitmq -e RABBITMQ_DEFAULT_USER=user -e RABBITMQ_DEFAULT_PASS=password rabbitmq:3-management`

3) Запуск mongodb
`docker run -d --hostname mongodb --name mongodb-name --network=local_docker --network-alias=mongodb mongo:4.4.3`

4)Запускаем сервисы
`docker run -d --hostname search_crawler --name search_crawler-name --network=local_docker --network-alias=search_crawler %GITHUBUSER%/search_crawler:1.0`
`docker run -d --hostname search_ui --name search_ui-name --network=local_docker --network-alias=search_ui -p 8000:8000 %GITHUBUSER%/search_ui:1.0`

Если открывается `http://localhost:8000/` - это знак хороший.

## 3.2. Поднимаем приложения в k8s (с kubectl)

1. `cd kubernetes/Apps`
2. `kubectl apply -f .`
3. `kubectl get ingress`
Ищем IP ingress'a (он также нужен для генерации сертификата)
4. Ждём около 5 минут пока раздуплиться UI
5. `http://ingress_ip` -> профит

### Настройка HTTPS

1. Раcкомментируем строчки для `ui-ingress.yml`
2. Генерируем сертификат для https
`openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=34.117.102.70"`
3. Копируем его в кластер
`kubectl create secret tls ui-ingress --key tls.key --cert tls.crt`
4. `kubectl apply -f ui-ingress.yml`
5. `https://ingress_ip` -> профит

## 3.3. Поднимаем приложение с помощью helm (k8s)

1. `cd kubernetes/Charts/search-engine-app && helm dep update && cd .. && helm install search-engine-app --name search-engine`   -  аля не продакшн версия
2. `helm install search-engine-app --name search-engine --namespace production`   -  аля продакшн версия


## 4. Создание pipeline для непрерывного тестирования и раскатки новых релизов

## 4.1 Установка и запуск Gitlab-CI

1. В директории `./gitlab-ci/terraform` выполнить команду `terraform apply`;
2. В директории `./gitlab-ci/ansible` выполнить команду `ansible-playbook playbooks/install_docker.yml`;
3. Подключиться по ssh к созданному инстансу gitlab;

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
git remote add gitlab http://<gitlab-vm-ip>/otus-project/diploma
git push gitlab gitlab-ci
```

## 4.3 Подключение к проекту созданного k8s-кластера

1. Получить адрес Kubernetes API:

`kubectl cluster-info | grep 'Kubernetes master' | awk '/http/ {print $NF}'`

2. Получить список секретов кластера:

`kubectl get secrets`

3. Получить сертификат:

`kubectl get secret <default-token-31337> -o jsonpath="{['data']['ca\.crt']}" | base64 --decode`

4. Задеплоить gitlab-admin-service-account.yml и получить токен для gitlab-admin:


```
kubectl apply -f gitlab-admin-service-account.yaml
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep gitlab-admin | awk '{print $1}')
```

5. Подключить с помощью полученных сертификатов и токенов кластер через Gitlab-CI UI.

## 4.4 Описание pipeline и тестирование приложения

Описание pipeline находится в файле `.gitlab-ci.yml` в корне репозитория.

