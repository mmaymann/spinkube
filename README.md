# Spinkube

## Run initially
chmod +x setup.sh<br>
./setup.sh

## Run after starting Codespace
\# start cluster<br>
k3d cluster start wasm-cluster<br>
<br>
\# simple-spinapp<br>
k port-forward svc/simple-spinapp 8083:80<br>
\# Start split terminal and run: >curl localhost:8083/hello<"<br>
kubectl delete -f simple-app/simple.yaml<br>
<br>
\# typescript-maymann<br>
k port-forward svc/typescript-maymann 8084:80<br>
\# Start split terminal and run: >curl localhost:8084<"<br>
kubectl delete -f typescript/app.yaml<br>

\# .NET<br>
@mmaymann ➜ /workspaces/spinkube/dotnet (main) $ spin up<br>
Logging component stdio to ".spin/logs/"<br>
Error: Failed to instantiate component 'dotnet'<br>
<br>
Caused by:<br>
   0: failed to validate component output<br>
   1: core instance 2 has no export named `canonical_abi_free` (at offset 0xac14bf)<br>

## Run before stopping Codespace
k3d cluster stop wasm-cluster
