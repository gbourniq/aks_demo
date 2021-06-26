#!/usr/bin/env bash
# Ref: https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx

K8S_APP_NAME="${K8S_APP_NAME:-ingress-nginx}"
CLUSTER_NAMESPACE="${CLUSTER_NAMESPACE:-load-balancer}"

echo $'\n\t>> Removing ingress-nginx using helm...\n'
helm uninstall "${K8S_APP_NAME}" --namespace "${CLUSTER_NAMESPACE}"