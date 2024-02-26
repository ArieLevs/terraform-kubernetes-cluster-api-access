# a kubernetes provider must be defined so that terraform is able to deploy resources to cluster
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# vault provider must ber defined if jenkins k8s api access should be stored in vault
# make sure to execute:
# export VAULT_ADDR="https://vault_addr"
# export VAULT_TOKEN="vault_token"
# before login
provider "vault" {
}

module "jenkins" {
  source = "../.."

  service_name = "jenkins-remote-cloud"
  # for example if a pre created resource needs to be annotated in current sa
  service_account_annotations = {
    "eks.amazonaws.com/role-arn" : "arn:aws:iam::123456789123:role/jenkins-agent"
  }
  namespace        = "jenkins-agents"
  create_namespace = true
  service_roles = {
    pod_control = {
      api_groups     = [""]
      resources      = ["pods"]
      resource_names = [""]
      verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    }
    pod_exec = {
      api_groups     = [""]
      resources      = ["pods/exec"]
      resource_names = [""]
      verbs          = ["create", "delete", "get", "list", "patch", "update", "watch"]
    }
    pod_logs = {
      api_groups     = [""]
      resources      = ["pods/log"]
      resource_names = [""]
      verbs          = ["get", "list", "watch"]
    }
    get_secrets = {
      api_groups     = [""]
      resources      = ["secrets"]
      resource_names = [""]
      verbs          = ["get"]
    }
  }

  kubernetes_cluster_endpoint = "https://kubernetes.docker.internal:6443"
  vault_store_argocd_access   = true
  vault_mount_path            = "secret"
  vault_secret_path           = "jenkins/remote-clouds/example"
}