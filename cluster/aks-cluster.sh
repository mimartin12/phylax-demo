#!/bin/bash

# Validate that kubectl, azcli, and kustomize are installed.
for cmd in kubectl az kustomize; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: $cmd is not installed. Please install $cmd and try again."
    echo "Instructions on installing $cmd can be found in the README."
    exit 1
  fi
done

# Quick bootstrapping of an AKS cluster for Phylax deployments
az group create --name phylax --location eastus

# Create AKS cluster with Cilium CNI
az aks create -n phylax-aks -g phylax -l eastus \
  --network-plugin azure \
  --network-plugin-mode overlay \
  --pod-cidr "192.168.0.0/16" \
  --network-dataplane cilium \
  --node-vm-size standard_a2_v2 \
  --node-count 2

# Pull credentials for the cluster
az aks get-credentials --resource-group phylax --name phylax-aks
kubectl config use-context phylax-aks

# Bootstrap the cluster
./bootstrap-k8s.sh

