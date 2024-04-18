# Spinkube

## Run after starting Codespace
k3d cluster start wasm-cluster<br>
kubectl port-forward svc/simple-spinapp 8083:80<br>
. # Start split terminal and run: >curl localhost:8083/hello<"

## Run before stopping Codespace
k3d cluster stop wasm-cluster
