# ArgoCD Remote Cluster

This is an example for preparing a k8s cluster to be connected as a remote cluster managed by ArgoCD.  
The example is basically an alternatie to the [cluster add](https://argo-cd.readthedocs.io/en/stable/user-guide/commands/argocd_cluster_add/) api from argocd cli.  

## Usage
Install Vault locally
```shell
helm repo add hashicorp https://helm.releases.hashicorp.com

helm upgrade vault \
  --install hashicorp/vault \
  --version 0.25.0 \
  --create-namespace \
  --namespace vault \
  -f ../values.vault.local.yaml
```
port forward to local vault
```shell
kubectl port-forward vault-0 8200:8200 -n vault
```

apply terraform
```shell
export VAULT_ADDR="http://127.0.0.1:8200/"
export VAULT_TOKEN="root"

terraform init
terraform apply
```