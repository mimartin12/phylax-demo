#!/bin/bash

# Deploy Nginx Ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.10.0/deploy/static/provider/cloud/deploy.yaml && \
    # Sleep works for now, but there is a better way to do this.
    sleep 30 && \
    kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s

# Install Cert Manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.4/cert-manager.yaml
kubectl wait --namespace cert-manager --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=180s


# Deploy the Phylax application
kubectl apply -k "phylax/overlays/prod"

# Query the IP address of the phylax ingress
export PHYLAX_IP=$(kubectl get ingress phylax-ingress -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "Update your DNS to point to $PHYLAX_IP"
echo "Ensure that spec.tls.hosts and spec.rules.host are updated in phylax/overlays/prod/ingress.yaml"