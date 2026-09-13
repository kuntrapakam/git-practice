resource "kubernetes_namespace" "testing" {
  metadata {
    name = "testing"
  }
}