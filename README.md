# terraform-kubernetes-cluster-api-access
Terraform module that prepares kubernetes for remote access

* users within the AWS ecosystem (EKS) - it is strongly advised to **not** use this module.  
  Instead, opting for the [EKS Access Entries](https://docs.aws.amazon.com/eks/latest/userguide/access-entries.html#creating-access-entries) feature is recommended.   
  This feature employs a temporary token, leveraging the native AWS API for enhanced functionality and security.

## Usage
```hcl
module "example" {
  source  = "ArieLevs/cluster-api-access/kubernetes"
  version = "1.0.2"

  service_name                    = "argocd-remote-cluster"
  create_cluster_wide_permissions = true

  kubernetes_cluster_endpoint = "https://kubernetes.docker.internal:6443"
  vault_store_argocd_access   = true
  vault_mount_path            = "secret"
  vault_secret_path           = "argocd/remote-clusters/example"
}
```

## Examples
- [ArgoCD](https://github.com/ArieLevs/terraform-kubernetes-cluster-api-access/tree/master/examples/argocd): Prepare kubernetes for argocd managed cluster
- [Jenkins](https://github.com/ArieLevs/terraform-kubernetes-cluster-api-access/tree/master/examples/jenkins): Prepare kubernetes for Jenkins remote clouds

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 3.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.0 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | >= 3.12 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubernetes_cluster_role.cluster_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.cluster_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_role.role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role) | resource |
| [kubernetes_role_binding.role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/role_binding) | resource |
| [kubernetes_secret.secret_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account.service_account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [vault_kv_secret_v2.remote_cluster](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_cluster_wide_permissions"></a> [create\_cluster\_wide\_permissions](#input\_create\_cluster\_wide\_permissions) | If set to true, module will create cluster wide role an role bindings | `string` | `false` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | If true, module will also create the namespace resource would be deployed to | `bool` | `false` | no |
| <a name="input_kubernetes_cluster_endpoint"></a> [kubernetes\_cluster\_endpoint](#input\_kubernetes\_cluster\_endpoint) | Endpoint for your Kubernetes API server | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to deploy all resources to | `string` | `"kube-system"` | no |
| <a name="input_service_account_annotations"></a> [service\_account\_annotations](#input\_service\_account\_annotations) | A map with the service account metadata annotations | `map(string)` | `{}` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of service to create, this name will be globally used across module resources | `string` | n/a | yes |
| <a name="input_service_roles"></a> [service\_roles](#input\_service\_roles) | Rules that represent a set of permissions | <pre>map(object({<br>    api_groups     = list(string)<br>    resources      = list(string)<br>    resource_names = optional(list(string))<br>    verbs          = list(string)<br>  }))</pre> | <pre>{<br>  "all": {<br>    "api_groups": [<br>      "*"<br>    ],<br>    "resource_names": [],<br>    "resources": [<br>      "*"<br>    ],<br>    "verbs": [<br>      "*"<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_vault_mount_path"></a> [vault\_mount\_path](#input\_vault\_mount\_path) | Path where KV-V2 engine is mounted | `string` | `""` | no |
| <a name="input_vault_secret_path"></a> [vault\_secret\_path](#input\_vault\_secret\_path) | Full name of the secret path to store argocd k8s api access | `string` | `""` | no |
| <a name="input_vault_store_argocd_access"></a> [vault\_store\_argocd\_access](#input\_vault\_store\_argocd\_access) | If true a remote kubernetes api access values will be stored back to a vault server | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->