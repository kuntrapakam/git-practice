#!/bin/bash

set -euo pipefail

echo "Checking Minikube installation..."

# Verify minikube is installed
if ! command -v minikube >/dev/null 2>&1; then
    echo "ERROR: Minikube is not installed or not available in PATH."
    exit 1
fi

echo "Minikube found: $(minikube version --short)"

# Check if cluster is already running
STATUS=$(minikube status --format='{{.Host}}' 2>/dev/null || echo "Stopped")

if [[ "$STATUS" == "Running" ]]; then
    echo "Minikube cluster is already running."
    minikube status
    exit 0
fi

echo "Starting Minikube with 2 nodes..."
minikube start --nodes 2

echo "Minikube cluster started successfully."

echo "Cluster information:"
minikube status
kubectl get nodes -o wide