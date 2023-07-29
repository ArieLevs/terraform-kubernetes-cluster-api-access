# a kubernetes provider must be defined so that terraform is able to deploy resources to cluster
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# vault provider must ber defined if argocd k8s api access should be stored in vault
# make sure to execute:
# export VAULT_ADDR="https://vault_addr"
# export VAULT_TOKEN="vault_token"
# before login
provider "vault" {
}

module "argocd" {
  source = "../.."

  service_name                    = "argocd-remote-cluster"
  create_cluster_wide_permissions = true

  kubernetes_cluster_endpoint = "https://kubernetes.docker.internal:6443"
  vault_store_argocd_access   = true
  vault_mount_path            = "secret"
  vault_secret_path           = "argocd/remote-clusters/example"
}