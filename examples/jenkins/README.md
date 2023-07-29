# Jenkins K8S plugin remote cloud

This is an example for preparing a k8s cluster to be connected as a remote cloud Jenkins agents runner.  
If you are using [Kubernetes plugin for Jenkins](https://plugins.jenkins.io/kubernetes/), you may want to [configure](https://plugins.jenkins.io/kubernetes/#plugin-content-configuration) extra remote clouds in addition to the default local cloud.  
Using this example will prepare the remote cloud with relevant access, store values in vault.  

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