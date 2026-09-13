resource "kubernetes_namespace" "kubernetes_namespace" {
  metadata {
    name = "validator"
  }
}
