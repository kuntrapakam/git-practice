#!/bin/sh

set -e

CURRENT_POD=$(hostname)

echo "Checking cluster health..."
echo "Ignoring current pod: ${CURRENT_POD}"

FAILED=$(kubectl get pods -A \
  -o jsonpath='{range .items[*]}{.metadata.namespace}{" "}{.metadata.name}{" "}{.status.containerStatuses[*].ready}{"\n"}{end}' \
  | grep false \
  | grep -v "${CURRENT_POD}" || true)

if [ -n "$FAILED" ]; then
  echo "Pods not ready:"
  echo "$FAILED"
  exit 1
fi

echo "All pods are healthy."