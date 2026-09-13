resource "kubernetes_pod" "curl_client" {

  metadata {
    name      = "curl-client"
    namespace = kubernetes_namespace.testing.metadata[0].name
  }

  spec {

    container {

      name  = "curl-client"
      image = "ubuntu:24.04"

      command = [
        "/bin/bash",
        "-c",
        <<-EOF
        apt-get update &&
        apt-get install -y curl &&
        sleep infinity
        EOF
      ]
    }
  }
}