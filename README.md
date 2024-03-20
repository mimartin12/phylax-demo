# Getting Started

=================

* [Design](./DESIGN.md)
* [Prerequisites](#prerequisites)
* [Setup](#setup)
  * [Create the AKS cluster](#create-the-aks-cluster)
  * [Bootstrap cluster](#bootstrap-cluster)
* [Wrapping up](#wrapping-up)
  * [Deploying a new environment](#deploying-a-new-environment)
  * [Updating the image](#updating-the-image)
  * [Adding environment variables](#adding-environment-variables)

## Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [kustomize](https://kubectl.docs.kubernetes.io/installation/kustomize/)
- [az](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)

## Setup

The majority of setup for the cluster is handled by the various bash scripts, however the Cert Manager and HTTPS configuration of this deployment does require a custom domain along with DNS entries to be updated so that the ingress controller can route traffic to the Phylax service and so that Cert Manager can validate the domain.

I did this by just getting a cheap domain and setting up the DNS in Cloudflare. This was a simple task and can be done in a few minutes.

- Order a cheap domain from a domain registrar, like [Namecheap](https://www.namecheap.com/)
- Create an account on Cloudflare and add the domain to your account. Follow the instructions on [Cloudflare's domain transfer guide](https://developers.cloudflare.com/registrar/get-started/transfer-domain-to-cloudflare/).

If you currently have a domain and DNS provider, you can use that just as easily.

Lastly, you will need to update the `cluster/overlays/prod/ingress-patch.yaml` file with your domain names. Simply replace the value `idkthisisademo.lol` with your domain.

### Create the AKS cluster

Use the `aks-cluster.sh` script to create the AKS cluster. This __does__ require you to authenticate to Azure with the `az` CLI. If you don't currently have a subscription, you can sign up for a free trial and get $200 in credits to use for 30 days [here](https://azure.microsoft.com/en-us/free/).

```bash
az login
./cluster/aks-cluster.sh
```

### Bootstrap cluster

We use `bootstrap-k8s.sh` to install the Nginx Ingress Controller and Cert Manager. This script also creates the Phyalx deployment from the prod overlay folder. It will output a Public IP address you can use to create an A record in your DNS provider.

```bash
./cluster/bootstrap-k8s.sh
```

### Wrapping up

You should now be able to access the Phylax service with the domain you set up. You can view the pods and services with `kubectl` by running `kubectl get -all -n phylax-prod`.


#### Deploying a new environment

To create a separate deployment, simply perform the following.

```bash
cp -r phylax/overlays/prod phylax/overlays/<name>
```

Update the `kustomization.yaml` file in the new overlay folder to use a new namespace by changing the value of `namespace:`.

Update the `ingress-patch.yaml` file in the new overlay folder to use your new domain.

Then run `kubectl apply -k phylax/overlays/<name>` to deploy the new environment.

#### Updating the image

Kustomize makes it easy to update an image in an overlay. 
Simply run `kustomize edit set image ghcr.io/phylax-systems/phylax:<version>` and then run `kubectl apply -k phylax/overlays/<name>` to update the deployment.

#### Adding environment variables

Environment variables are handled by Kustomize's `ConfigMapGenerator`. Each overlay contains a `.env` file, this is where new environment variables can be added. When applied with `kubectl apply -k phylax/overlays/<name>`, the ConfigMap will be updated, and the deployment will be updated with the new environment variables.