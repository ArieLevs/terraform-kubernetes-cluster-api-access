resource "kubernetes_namespace" "namespace" {
  count = var.create_namespace ? 1 : 0

  metadata {
    name = var.namespace
    labels = {
      terraform = "true"
    }
  }
}

# create service account to be used to authenticated to kubernetes api
resource "kubernetes_service_account" "service_account" {
  metadata {
    name        = var.service_name
    annotations = var.service_account_annotations
    namespace   = var.namespace
    labels = {
      terraform = "true"
    }
  }

  depends_on = [kubernetes_namespace.namespace]
}

resource "kubernetes_secret" "secret_token" {
  metadata {
    name      = "${var.service_name}-token"
    namespace = kubernetes_service_account.service_account.metadata[0].namespace
    annotations = {
      "kubernetes.io/service-account.name"      = kubernetes_service_account.service_account.metadata[0].name
      "kubernetes.io/service-account.namespace" = kubernetes_service_account.service_account.metadata[0].namespace
    }
    labels = {
      terraform = "true"
    }
  }
  type                           = "kubernetes.io/service-account-token"
  wait_for_service_account_token = true

  depends_on = [kubernetes_service_account.service_account]
}

resource "kubernetes_role" "role" {
  count = var.create_cluster_wide_permissions ? 0 : 1

  metadata {
    name      = var.service_name
    namespace = kubernetes_service_account.service_account.metadata[0].namespace
    labels = {
      terraform = "true"
    }
  }

  dynamic "rule" {
    for_each = var.service_roles
    content {
      api_groups     = rule.value["api_groups"]
      resources      = rule.value["resources"]
      resource_names = rule.value["resource_names"]
      verbs          = rule.value["verbs"]
    }
  }

  depends_on = [kubernetes_service_account.service_account]
}

resource "kubernetes_role_binding" "role_binding" {
  count = var.create_cluster_wide_permissions ? 0 : 1

  metadata {
    name      = var.service_name
    namespace = kubernetes_role.role[0].metadata[0].namespace
    labels = {
      terraform = "true"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.role[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.service_account.metadata[0].name
    namespace = kubernetes_service_account.service_account.metadata[0].namespace
  }

  depends_on = [kubernetes_service_account.service_account, kubernetes_role.role]
}

resource "kubernetes_cluster_role" "cluster_role" {
  count = var.create_cluster_wide_permissions ? 1 : 0

  metadata {
    name = var.service_name
    labels = {
      terraform = "true"
    }
  }

  dynamic "rule" {
    for_each = var.service_roles
    content {
      api_groups     = rule.value["api_groups"]
      resources      = rule.value["resources"]
      resource_names = rule.value["resource_names"]
      verbs          = rule.value["verbs"]
    }
  }

  depends_on = [kubernetes_service_account.service_account]
}

resource "kubernetes_cluster_role_binding" "cluster_role_binding" {
  count = var.create_cluster_wide_permissions ? 1 : 0

  metadata {
    name = var.service_name
    labels = {
      terraform = "true"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.cluster_role[0].metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.service_account.metadata[0].name
    namespace = kubernetes_service_account.service_account.metadata[0].namespace
  }

  depends_on = [kubernetes_service_account.service_account, kubernetes_cluster_role.cluster_role]
}

# store created secrets to vault
resource "vault_kv_secret_v2" "remote_cluster" {
  count = var.vault_store_argocd_access ? 1 : 0

  mount = var.vault_mount_path
  name  = var.vault_secret_path
  cas   = 1

  data_json = jsonencode(
    {
      kubernetes_url        = var.kubernetes_cluster_endpoint,
      kubernetes_cluster_ca = kubernetes_secret.secret_token.data["ca.crt"],
      kubernetes_token      = kubernetes_secret.secret_token.data["token"]
    }
  )

  custom_metadata {
    max_versions = 5
    data = {
      terraform = "true"
    }
  }

  depends_on = [kubernetes_secret.secret_token]
}