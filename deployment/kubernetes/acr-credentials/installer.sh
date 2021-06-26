#!/usr/bin/env bash
set -e

CLUSTER_NAMESPACE="${CLUSTER_NAMESPACE:-aks-demo-playground}"
ACR_REGISTRY="gbournique.azurecr.io"
ACR_USERNAME="gbournique"

kubectl create secret docker-registry acr-credentials \
    --namespace $CLUSTER_NAMESPACE \
    --docker-server=$ACR_REGISTRY \
    --docker-username=$ACR_USERNAME \
    --docker-password=$ACR_PASSWORD
