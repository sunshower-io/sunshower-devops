#!/usr/bin/env bash

export HOST0=$1
export HOST1=$2
export HOST2=$3


mkdir -p /tmp/"${HOST0}"/ /tmp/"${HOST1}"/ /tmp/"${HOST2}"/
ETCDHOSTS=("${HOST0}" "${HOST1}" "${HOST2}")
NAMES=("etcd1" "etcd2" "etcd3")

for i in "${!ETCDHOSTS[@]}"; do
HOST=${ETCDHOSTS[$i]}
NAME=${NAMES[$i]}
cat << EOF > /tmp/${HOST}/kubeadmcfg.yaml
apiVersion: "kubeadm.k8s.io/v1beta1"
kind: ClusterConfiguration
etcd:
    local:
        serverCertSANs:
        - "${HOST}"
        peerCertSANs:
        - "${HOST}"
        extraArgs:
            initial-cluster: ${NAMES[0]}=https://${ETCDHOSTS[0]}:2380,${NAMES[1]}=https://${ETCDHOSTS[1]}:2380,${NAMES[2]}=https://${ETCDHOSTS[2]}:2380
            initial-cluster-state: new
            name: ${NAME}
            listen-peer-urls: https://${HOST}:2380
            listen-client-urls: https://${HOST}:2379
            advertise-client-urls: https://${HOST}:2379
            initial-advertise-peer-urls: https://${HOST}:2380
EOF
done
kubeadm init phase certs etcd-ca

function create_certs() {
  local node=$1
  kubeadm init phase certs etcd-server --config=/tmp/"${node}"/kubeadmcfg.yaml
  kubeadm init phase certs etcd-peer --config=/tmp/"${node}"/kubeadmcfg.yaml
  kubeadm init phase certs etcd-healthcheck-client --config=/tmp/"${node}"/kubeadmcfg.yaml
  kubeadm init phase certs apiserver-etcd-client --config=/tmp/"${node}"/kubeadmcfg.yaml
  cp -R /etc/kubernetes/pki /tmp/"${node}"/
}

for i in "${!ETCDHOSTS[@]}"; do
  HOST=${ETCDHOSTS[$i]}
  create_certs "$HOST"
done

find /tmp/"${HOST2}" -name ca.key -type f -delete
find /tmp/"${HOST1}" -name ca.key -type f -delete
