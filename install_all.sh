#!/bin/bash

# Script settings
PROJECT_ID="diploma-301517"
ZONE="europe-west1-b"
MONITORING_NAME="monitoring-system"
NON_RELEASE_NAME="search-engine"
RELEASE_NAME="search-engine-prod"

# Colored output
RED="\033[0;31m"
NC="\033[0m" # No Color

print () {
  printf "\n\n##########################\n${RED}$1${NC}\n##########################\n\n"
}

print "Creating k8s cluster"
cd ./terraform/k8s-cluster
terraform apply -auto-approve
print "Connecting to k8s cluster"
gcloud container clusters get-credentials gke-cluster --zone $ZONE --project $PROJECT_ID
print "Init tiller plugin"
cd ../../kubernetes/Charts && kubectl apply -f tiller.yml
print "Lets take some time for tiller deploy. (Sleep 30s)"
sleep 30
print "Init account and wait some time"
helm init --service-account tiller
sleep 30
print "Installing monitoring system"
cd ./prometheus && helm dep update && cd .. && helm install prometheus --name $MONITORING_NAME
print "Installing non-release application version"
cd ./search-engine-app && helm dep update && cd .. && helm install search-engine-app --name $NON_RELEASE_NAME
print "Installing release application version"
helm install search-engine-app --name $RELEASE_NAME --namespace production
print "Waiting for applications up and running (sleep 2 mins)"
sleep 2m
print "Please add this ip to hosts file (for prometeus + grafana)"
kubectl get svc | grep $MONITORING_NAME-nginx-ingress-controller
print "This is non-release application IP:"
kubectl get svc | grep $NON_RELEASE_NAME-search-ui
print "This is release application IP:"
kubectl get svc --namespace production | grep $RELEASE_NAME-search-ui
