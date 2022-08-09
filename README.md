# Overview

Script will create dev Kubernetes environment for dev or tests via Kind

1. Create registry for multi node cluster
2. Create registry proxy for docker.io and quay.io
3. Create cluster k8s

## How to run
```sh
export WORKERS_NUM=0
./kind-dev-cluster.sh
```

## Requirements
Docker
k3d
kind