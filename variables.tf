variable "service_name" {
  description = "Name of service to create, this name will be globally used across module resources"
  type        = string
}

variable "namespace" {
  description = "Namespace to deploy all resources to"
  type        = string
  default     = "kube-system"
}

variable "create_namespace" {
  description = "If true, module will also create the namespace resource would be deployed to"
  type        = bool
  default     = false
}

variable "service_roles" {
  description = "Rules that represent a set of permissions"
  type = map(object({
    api_groups     = list(string)
    resources      = list(string)
    resource_names = list(string)
    verbs          = list(string)
  }))
  default = {
    all = {
      api_groups     = ["*"]
      resources      = ["*"]
      resource_names = []
      verbs          = ["*"]
    }
  }
}

variable "create_cluster_wide_permissions" {
  description = "If set to true, module will create cluster wide role an role bindings"
  type        = string
  default     = false
}

variable "vault_store_argocd_access" {
  description = "If true a remote kubernetes api access values will be stored back to a vault server"
  type        = bool
  default     = false
}

variable "vault_mount_path" {
  description = "Path where KV-V2 engine is mounted"
  type        = string
  default     = ""
}

variable "vault_secret_path" {
  description = "Full name of the secret path to store argocd k8s api access"
  type        = string
  default     = ""
}

variable "kubernetes_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
  default     = ""
}