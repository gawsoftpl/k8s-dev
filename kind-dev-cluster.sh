#!/bin/bash

reg_port='5000'
reg_name='kind-registry'
WORKERS_NUM=${WORKERS_NUM:-0}

# Docker image registry for multi node cluster
if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
  echo "Create docker registry if not exists"
  docker run \
    -d --restart=always -v $HOME/registry:/var/lib/registry -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
    registry:2
fi

# Docker proxy for speedup load images from docker.io and quay
echo "Start create docker.io proxy registry"
k3d registry create docker-io-proxy  \
  -p 5001 \
  --proxy-remote-url https://registry-1.docker.io  \
  -v $HOME/registry/proxy/docker.io:/var/lib/registry || true

echo "Start create quay.io proxy registry"
k3d registry create quay-proxy  \
  -p 5002 \
  --proxy-remote-url https://quay.io  \
  -v $HOME/registry/proxy/quay.io:/var/lib/registry || true


# Create cluster and import private docker registry credentials
cat << EOF > /tmp/kind.cluster.yml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: apiserver-dev
networking:
  podSubnet: "10.244.0.0/16"
containerdConfigPatches:
  - |-
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_port}"]
      endpoint = ["http://kind-registry:5000"]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
      endpoint = ["http://k3d-docker-io-proxy:5000"]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."quay.io"]
      endpoint = ["http://k3d-quay-proxy:5000"]

nodes:
  - role: control-plane
    extraMounts:
      - containerPath: /var/lib/kubelet/config.json
        hostPath: ${HOME}/.docker/config.json
EOF

# Create workers info
for i in $(seq 1 $WORKERS_NUM); do
echo "  - role: worker" >> /tmp/kind.cluster.yml
done

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

kind create cluster --config /tmp/kind.cluster.yml --wait 3m

# Assign dockers with one network
docker network connect "kind" "${reg_name}"
docker network connect "kind" "k3d-docker-io-proxy"
docker network connect "kind" "k3d-quay-proxy"
