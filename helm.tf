resource "helm_release" "fluentbit" {
  name             = "fluent-bit"
  repository       = "https://fluent.github.io/helm-charts"
  chart            = "fluent-bit"
  namespace        = "logging"
  create_namespace = true

  timeout = 600
  atomic  = true

  values = [
    file("${path.module}/values/fluent-bit-values.yaml")
  ]
  depends_on = [
    helm_release.grafana
  ]
}
