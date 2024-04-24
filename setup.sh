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

# Install spin
# https://www.typescripttutorial.net/typescript-tutorial/typescript-hello-world/
# https://developer.fermyon.com/wasm-languages/typescript
# https://www.fermyon.com/blog/spin-js-sdk
# https://www.youtube.com/watch?v=435WOVEl4ww
sudo apt install -y node-typescript npm spin
curl -fsSL https://developer.fermyon.com/downloads/install.sh | bash
sudo mv spin /usr/local/bin/
spin plugins update
spin plugins install pluginify --yes
spin plugins install js2wasm --yes
spin plugins install kube --yes
git clone https://github.com/fermyon/spin-trigger-command
cd https://github.com/fermyon/spin-trigger-command
cargo build --release
spin pluginify --install
cd ..

# Create typescript app
spin new -t http-js typescript -a
cd typescript
tee -a index.js << END
export async function handleRequest(request) {

    console.log('Handling request ${JSON.stringify(request)}')

    return {
        status: 200,
        headers: { "content-type": "text/plain" },
        body: "Hello, Typescript"
    }
}
END
npm install
spin build
spin registry push ttl.sh/typescript-maymann:1h
spin kube scaffold -f ttl.sh/typescript-maymann:1h > typescript.yaml
kubectl apply -f typescript.yaml
cd ..

# Install .NET
# https://developer.fermyon.com/wasm-languages/c-sharp
curl -sL https://deb.nodesource.com/setup_16.x -o /tmp/nodesource_setup.sh
sudo /tmp/nodesource_setup.sh
sudo apt install -y dotnet-sdk-8.0 cargo nodejs
cargo install wizer --all-features
sudo dotnet workload install wasi-experimental
curl https://wasmtime.dev/install.sh -sSf | bash

# Create .NET app
git clone https://github.com/radu-matei/spin-trigger-csharp-test
mv spin-trigger-csharp-test dotnet
cd dotnet
...
spin build
spin registry push ttl.sh/dotnet-maymann:1h
spin kube scaffold -f ttl.sh/dotnet-maymann:1h > dotnet.yaml
kubectl apply -f dotnet.yaml
cd ..


### Delete everything after this line when we have above working
mkdir dotnet
cd dotnet
dotnet new wasiconsole
dotnet build
tee -a spin.toml << END
spin_version = "1"
name = "spin-test"
trigger = { type = "http", base = "/" }
version = "1.0.0"

[[component]]
id = "spin-page"
source = "bin/Debug/net8.0/wasi-wasm/dotnet.wasm"
[component.trigger]
route = "/"
executor = { type = "wagi" }
END
spin build
spin registry push ttl.sh/dotnet-maymann:1h
spin kube scaffold -f ttl.sh/dotnet-maymann:1h > dotnet.yaml
kubectl apply -f dotnet.yaml

#git clone https://github.com/fermyon/spin-dotnet-sdk
#cd spin-dotnet-sdk/samples/helloworld
cd ..

# Build WASI SDK
mkdir wasi-sdk
cd wasi-sdk
git clone https://github.com/SteveSandersonMS/dotnet-wasi-sdk
cd dotnet-wasi-sdk
git submodule update --init --recursive
sudo apt-get install -y build-essential cmake ninja-build python python3 zlib1g-dev
cd modules/runtime/src/mono/wasm
make provision-wasm
make build-all
cd ../wasi
make
