#!/bin/bash
# Delete default k3d cluster
k3d cluster stop k3s-default
k3d cluster delete k3s-default

# Create WASM cluster
k3d cluster create wasm-cluster --image ghcr.io/spinkube/containerd-shim-spin/k3d:v0.13.1 --port "8081:80@loadbalancer" --agents 2
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.3/cert-manager.yaml
sleep 30
kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.runtime-class.yaml
kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.crds.yaml

# Deploy Spin Operator
helm install spin-operator --namespace spin-operator --create-namespace --version 0.1.0 --wait oci://ghcr.io/spinkube/charts/spin-operator
kubectl apply -f https://github.com/spinkube/spin-operator/releases/download/v0.1.0/spin-operator.shim-executor.yaml

# Run sample app
kubectl apply -f https://raw.githubusercontent.com/spinkube/spin-operator/main/config/samples/simple.yaml

# Create typescript app
# https://www.typescripttutorial.net/typescript-tutorial/typescript-hello-world/
# https://developer.fermyon.com/wasm-languages/typescript
# https://www.fermyon.com/blog/spin-js-sdk

# Create .NET app
# https://developer.fermyon.com/wasm-languages/c-sharp
