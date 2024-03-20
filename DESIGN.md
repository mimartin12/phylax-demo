# Design

## Proposal

A Kubernetes application deployment, using industry standard tooling.

## Goal

Create a scalable and maintainable deployment infrastructure for Phylax using industry standard tooling to enable high rate of deployments into Kubernetes.

The proposed solution ensures that the following goals are met:

- Phylax is running as a scalable Kubernetes deployment
- Phylax deployments into environments can be scalable and repeatable.
- Deployment manifests are modular and well structured.
- Phylax deployments are secure, allowing only nginx ingress traffic.
- Connections to the Phylax API are secured using TLS.


## Architecture

The deployment infrastructure leverages Kustomize to deploy Phylax into a Kubernetes cluster, using a modular `base` and `overlays` to achieve environment specific configuration. Deployments for this demo happen on Azure Kubernetes Service (AKS), but as the manifests are agnostic, any Kubernetes cluster with Cilium as the CNI can be used.

For the sake of simplicity, commands that create the cluster and deploy the Kubernetes applications are all performed using CLI commands. This was simply a time constraint issue. In a real world scenario, cluster deployments would be handled by Terraform and bootstrapping of the cluster would be performed by Argo CD.

Ingress is handled by the Nginx Ingress Controller, deployed via the `bootstrap-cluster.sh` script file. This allows for a single point of entry into the cluster, and allows for secure connections to the Phylax API using TLS.

Automated SSL certificate management is handled by cert-manager, which is also deployed as part of the `bootstrap-cluster.sh` script. This allows for the automatic generation and renewal of SSL certificates for the Phylax API.

__ Architecture choice: Kustomize__
The decision to use Kustoimze allows the deployment manifests to be modular and well structured. While Helm is also a viable solution and is very popular in the community. It's often overkill for simple deployments. The tempalting can be rather complex and with Helm comes a lot of inherit process that is needed to ship fast.

__ Architecture choice: Cert Manager__
Cert-manager allows for the automatic generation and renewal of SSL certificates for the Phylax API. This is a key requirement for the Phylax API to be secure and to be able to be accessed by the public in a secure fashion. Cert Manager is a popular choice in the community and is well supported, it has a large amount of Cluster Issuers to choose from, making this flexible and easy to use.

__ Architecture choice: Nginx Ingress__
Nginx Ingress is a simple and community supported ingress controller. It's able to manage large amounts of traffic and distribute it through out the cluster. It's also able to handle SSL termination, which is a key requirement for the Phylax API to be secure.

## Deployment Pattern

The deployment manifest follows the standardization of Kustomize Overlays. `base/` handles all the common resources that are shared across all environments. `overlays/` contains the environment specific configuration. This allows for clear separation of concerns and enables us to simply create a new folder under `overlays/`, populate it with a `kustomization.yaml` file, and then add any specific environment configuration to deploy a new, separate environment.

## Security design

Using Cilium to enforce Kubernetes security policies, we can make it so that no traffic can access the Phylax pods except for the Nginx Ingress Controller. This secures the pods from any unwanted traffic and ensures that the Phylax API is only accessible through the Nginx Ingress Controller. This is done by applying the network policy `phylax/base/network-policy.yaml`.

