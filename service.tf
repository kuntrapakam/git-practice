resource "kubernetes_service" "log_generator" {

  metadata {
    name      = "log-generator"
    namespace = kubernetes_namespace.testing.metadata[0].name
  }

  spec {

    selector = {
      app = "log-generator"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "ClusterIP"
  }
}