#!/usr/bin/env bash


export HOST0=$2
export HOST1=$3
export HOST2=$4

echo "installing etcd.  Targets:"
printf "\t %s" "$HOST0"
printf "\t %s" "$HOST1"
printf "\t %s" "$HOST2"

mkdir -p /tmp/"${HOST0}"/ /tmp/"${HOST1}"/ /tmp/"${HOST2}"/
ETCDHOSTS=("${HOST0}" "${HOST1}" "${HOST2}")
NAMES=("etcd-1" "etcd-2" "etcd-3")


for i in "${!ETCDHOSTS[@]}"; do
HOST=${ETCDHOSTS[$i]}
NAME=${NAMES[$i]}
cat << EOF > "/tmp/${HOST}/kubeadmcfg.yaml"
apiVersion: "kubeadm.k8s.io/v1beta2"
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
  local idx=$2
  echo "generating certs for $node"
  kubeadm init phase certs etcd-server --config="/tmp/${node}/kubeadmcfg.yaml"
  kubeadm init phase certs etcd-peer --config="/tmp/${node}/kubeadmcfg.yaml"
  kubeadm init phase certs etcd-healthcheck-client --config="/tmp/${node}/kubeadmcfg.yaml"
  kubeadm init phase certs apiserver-etcd-client --config="/tmp/${node}/kubeadmcfg.yaml"

  if [ "$idx" -ne 0 ]; then
    cp -R /etc/kubernetes/pki /tmp/"${node}"/
    find /etc/kubernetes/pki -not -name ca.crt -not -name ca.key -type f -delete
  fi

  echo "completed generating certs for $node"
}

for (( idx=${#ETCDHOSTS[@]}-1 ; idx>=0 ; idx-- )) ; do
  HOST=${ETCDHOSTS[$idx]}
  create_certs "$HOST" "$idx"
done


find /tmp/"${HOST2}" -name ca.key -type f -delete
find /tmp/"${HOST1}" -name ca.key -type f -delete

echo "generating ID..."
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null
echo "Successfully generated ID"

for i in "${ETCDHOSTS[@]:1}"; do
  echo "Copying files to $i"
  sshpass -p "$1" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no "root@$i"
  scp -r "/tmp/${i}/pki/" "root@${i}:/etc/kubernetes/"
  scp -r "/tmp/${i}/kubeadmcfg.yaml" "root@${i}:"
done

echo "Configuring etcd on $(ip route get 1 | cut -d ' ' -f7)"

kubeadm init phase etcd local --config="/tmp/$(ip route get 1 | cut -d ' ' -f7 | xargs)/kubeadmcfg.yaml"

echo "successfully configured etcd on $(ip route get 1 | cut -d ' ' -f7)"
