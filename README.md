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
wget https://raw.githubusercontent.com/spinkube/spin-operator/main/config/samples/simple.yaml -P /tmp<br>
kubectl delete -f /tmp/simple.yaml<br>
rm -rf /tmp/yaml<br>
<br>
\# typescript-maymann<br>
k port-forward svc/typescript-maymann 8084:80<br>
\# Start split terminal and run: >curl localhost:8084<"<br>
kubectl delete -f typescript/app.yaml<br>

## Run before stopping Codespace
k3d cluster stop wasm-cluster
