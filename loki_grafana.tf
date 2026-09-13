resource "helm_release" "loki_stack" {
  name       = "loki-stack"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki-stack"
  version    = "2.10.2"
  namespace  = "logging"

  create_namespace = true

  values = [
    yamlencode({
      loki = {
        enabled = true
        # Force a newer Loki version to prevent the Grafana compatibility bug
        image = {
          tag = "2.9.3" 
        }
      }

      promtail = {
        enabled = false
      }

      fluent-bit = {
        enabled = false
      }

      grafana = {
        enabled = false
      }
    })
  ]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "logging"

  values = [
    yamlencode({
      adminUser     = "admin"
      adminPassword = "admin123"

      datasources = {
        "datasources.yaml" = {
          apiVersion = 1

          datasources = [
            {
              name      = "Loki"
              type      = "loki"
              access    = "proxy"
              # Using the FQDN ensures the Grafana pod safely routes across the namespace
              url       = "http://loki-stack.logging.svc.cluster.local:3100"
              isDefault = true
              editable  = true
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    helm_release.loki_stack
  ]
}