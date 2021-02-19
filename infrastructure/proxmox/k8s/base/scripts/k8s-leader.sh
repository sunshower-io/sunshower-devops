#!/usr/bin/env bash

# copy certificates from ETCD leader to K8s leader
# call via ./k8s-leader.sh provision_leader_certs "leader-ip"
function provision_leader_certs() {
  ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null
  local leader=$1
  local password=$2
  sshpass -p "$password" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no "root@$leader"
  echo "Provisioning certificates for leader: $leader"
  scp /etc/kubernetes/pki/etcd/ca.crt "$leader:"
  scp /etc/kubernetes/pki/apiserver-etcd-client.crt "$leader:"
  scp /etc/kubernetes/pki/apiserver-etcd-client.key "$leader:"
  echo "Leader certificates provisioned"
}

# "private"--to be called by create_leader_cfg
function copy_certificates() {

  echo "Creating k8s directory..."
  mkdir -p /etc/kubernetes/pki/etcd/
  echo "Successfully created k8s directory"

  echo "copying files..."
  cp /root/ca.crt /etc/kubernetes/pki/etcd/
  cp /root/apiserver-etcd-client.crt /etc/kubernetes/pki/
  cp /root/apiserver-etcd-client.key /etc/kubernetes/pki/
}


# generate leader configuration
# call with ./k8s-leader.sh create_leader_cfg loadbalancer_ip etcd1 etcd2 etcd3
function create_leader_cfg() {
  local etcd1=$3
  local etcd2=$4
  local etcd3=$5
  local etcd_port=$2
  local load_balancer_ip=$1

  echo "Generating leader config: $load_balancer_ip at ($etcd1, $etcd2, $etcd3):$etcd_port"

  # ports aren't configurable right now.  Will fix in later versions (maybe)
  cat <<-EOF > /root/kubeadm-config.yaml
    apiVersion: kubeadm.k8s.io/v1beta2
    kind: ClusterConfiguration
    kubernetesVersion: stable
    apiServer:
      certSANs:
      - "$load_balancer_ip"
    controlPlaneEndpoint: "$load_balancer_ip:6443"
    etcd:
        external:
            endpoints:
            - https://$etcd1:2379
            - https://$etcd2:2379
            - https://$etcd3:2379
            caFile: /etc/kubernetes/pki/etcd/ca.crt
            certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
            keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
EOF
  echo "Successfully generated leader config: $load_balancer_ip at ($etcd1, $etcd2, $etcd3):$etcd_port"

  copy_certificates
  echo "Initiating kubeadm on $(uname -a)"
  until kubeadm init --config /root/kubeadm-config.yaml -v=5
  do
    echo "Init failed--retrying in 5 seconds..."
    sleep 5
  done
  echo "Successfully initialized first kubernetes leader!"


  echo "Installing Weave CNI..."
  kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
  echo "Successfully installed Weave CNI"


  echo "retrieving join command..."
  kubeadm token create --print-join-command > /tmp/join.sh
  echo "Successfully wrote join info to /tmp/join.sh"


}

if declare -f "$1" > /dev/null
then
  "$@"
else
  echo "'$1' does not exist " >&2
  exit 1
fi