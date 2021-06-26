#!/usr/bin/env bash
set -ex

# Ref: https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx

# Create public ip:
# az network public-ip create --resource-group MC_aks_demo_aks-demo-cluster_uksouth --name myAKSPublicIPForIngress --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv
PUBLIC_IP="20.90.188.180"
CLUSTER_NAMESPACE="${CLUSTER_NAMESPACE:-load-balancer}"

echo $'\n\t>> Deploying ingress-nginx using helm...\n'

# Create a namespace for the ingress resource if not existent
if ! kubectl get namespaces | grep $CLUSTER_NAMESPACE; then kubectl create namespace $CLUSTER_NAMESPACE; fi

# Add and update the official stable repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add stable https://charts.helm.sh/stable/
helm repo update

# Use Helm to deploy an NGINX ingress controller
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace $CLUSTER_NAMESPACE \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP=$PUBLIC_IP

# Access Public IP
echo "Ingress controller is now accessible at http://$PUBLIC_IP"
