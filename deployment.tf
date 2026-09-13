resource "kubernetes_deployment" "log_generator" {

  metadata {
    name      = "log-generator"
    namespace = kubernetes_namespace.testing.metadata[0].name

    labels = {
      app = "log-generator"
    }
  }

  spec {

    replicas = 1

    selector {
      match_labels = {
        app = "log-generator"
      }
    }

    template {

      metadata {
        labels = {
          app = "log-generator"
        }
      }

      spec {

        container {

          name  = "log-generator"
          image = "python:3.12"

          command = [
            "/bin/bash",
            "-c"
          ]

          args = [<<-EOF
cat > /tmp/server.py << 'PYTHON'
from http.server import BaseHTTPRequestHandler, HTTPServer
import urllib.parse
import time

class Handler(BaseHTTPRequestHandler):

    def do_GET(self):

        query = urllib.parse.parse_qs(
            urllib.parse.urlparse(self.path).query
        )

        count = int(query.get("count", ["3000"])[0])
        size = int(query.get("size", ["1024"])[0])
        duration = int(query.get("duration", ["300"])[0])

        if count <= 0:
            count = 1

        if duration <= 0:
            duration = 1

        rate = count / duration

        if rate < 1:
            interval = duration / count
        else:
            interval = 1 / rate

        payload = "X" * size

        print(
            f"Starting load test: count={count}, size={size}, duration={duration}",
            flush=True
        )

        for i in range(count):
            print(
                f"log_number={i+1} size={size} {payload}",
                flush=True
            )
            time.sleep(interval)

        self.send_response(200)
        self.send_header("Content-Type", "text/plain")
        self.end_headers()

        self.wfile.write(
            f"Generated {count} logs of {size} bytes over {duration} seconds\\n".encode()
        )

HTTPServer(("0.0.0.0", 8080), Handler).serve_forever()
PYTHON

python /tmp/server.py
EOF
          ]

          port {
            container_port = 8080
          }

          resources {

            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}