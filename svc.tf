resource "kubernetes_service_account" "health_check" {
  metadata {
    name      = "health-check-sa"
    namespace = "validator"
  }
}
resource "kubernetes_cluster_role" "health_check" {
  metadata {
    name = "health-check-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "nodes", "namespaces"]
    verbs      = ["get", "list"]
  }
}
resource "kubernetes_cluster_role_binding" "health_check" {
  metadata {
    name = "health-check-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.health_check.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.health_check.metadata[0].name
    namespace = "validator"
  }
}
resource "kubernetes_job" "health_check" {

  metadata {
    name      = "health-check"
    namespace = "validator"
  }

  spec {

    backoff_limit = 0

    template {

      metadata {}

      spec {

        service_account_name = kubernetes_service_account.health_check.metadata[0].name

        container {

          name  = "validator"
          image = "bitnami/kubectl:latest"

          command = [
            "/bin/sh",
            "/scripts/health-check.sh"
          ]

          volume_mount {
            name       = "scripts"
            mount_path = "/scripts"
          }
        }

        volume {
          name = "scripts"

          config_map {
            name         = kubernetes_config_map.health_script.metadata[0].name
            default_mode = "0755"
          }
        }

        restart_policy = "Never"
      }
    }
  }
}
resource "kubernetes_config_map" "health_script" {
  metadata {
    name      = "health-check-script"
    namespace = "validator"
  }

  data = {
    "health-check.sh" = file("${path.module}/scripts/health-check.sh")
  }
}
