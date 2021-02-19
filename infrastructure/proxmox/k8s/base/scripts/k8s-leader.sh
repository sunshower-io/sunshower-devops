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

  echo "Generating PK..."
  ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa <<<y 2>&1 >/dev/null
  echo "Successfully generated PK"

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
  until kubeadm init --config /root/kubeadm-config.yaml --upload-certs -v=5
  do
    echo "Init failed--retrying in 5 seconds..."
    sleep 5
  done
  echo "Successfully initialized first kubernetes leader!"


  echo "Installing Weave CNI..."
  kubectl --kubeconfig /etc/kubernetes/admin.conf apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
  echo "Successfully installed Weave CNI"


  echo "retrieving follower join command..."
  kubeadm token create --print-join-command > /tmp/join.sh
  echo "Successfully wrote join info to /tmp/join.sh"

  echo "retrieving leader join command..."
  echo "$(kubeadm token create --print-join-command) --control-plane" > /tmp/join-leader.sh
  echo "successfully retrieved leader join command"


  echo "Waiting for leader to become ready"
  until kubectl --kubeconfig /etc/kubernetes/admin.conf get nodes | grep -m 1 "Ready";
  do
    echo "Leader is not ready yet--will retry in 5 seconds"
    sleep 5
  done

  echo "Leader is ready"


}

# call ./k8s-leader.sh configure_second_leader k8s-leader-2.sunshower.cloud <username> <password>
function configure_second_leader() {
  local leader_2=$1
  local leader_2_pw=$3
  local leader_2_username=$2
  sshpass -p "$leader_2_pw" ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no "$leader_2_username@$leader_2"
  sshpass -p "$leader_2_pw" scp -r "/etc/kubernetes/admin.conf" "$leader_2_username@$leader_2:/etc/kubernetes/"
  sshpass -p "$leader_2_pw" scp -r "/tmp/join-leader.sh" "$leader_2_username@$leader_2:/tmp/"



  sshpass -p "$leader_2_pw" scp /etc/kubernetes/pki/ca.* "$leader_2_username@$leader_2:/etc/kubernetes/pki/"
  sshpass -p "$leader_2_pw" scp /etc/kubernetes/pki/sa.*  "$leader_2_username@$leader_2:/etc/kubernetes/pki/"
  sshpass -p "$leader_2_pw" scp /etc/kubernetes/pki/front-proxy-ca.key "$leader_2_username@$leader_2:/etc/kubernetes/pki/"
  sshpass -p "$leader_2_pw" scp /etc/kubernetes/pki/front-proxy-ca.crt "$leader_2_username@$leader_2:/etc/kubernetes/pki/"
  sshpass -p "$leader_2_pw" scp /etc/kubernetes/pki/etcd/ca.crt "$leader_2_username@$leader_2:/etc/kubernetes/pki/etcd/"
  sshpass -p "$leader_2_pw" scp /etc/kubernetes/pki/apiserver-etcd-client.crt "$leader_2_username@$leader_2:/etc/kubernetes/pki/"
  sshpass -p "$leader_2_pw" scp /etc/kubernetes/pki/apiserver-etcd-client.key "$leader_2_username@$leader_2:/etc/kubernetes/pki/"

}

if declare -f "$1" > /dev/null
then
  "$@"
else
  echo "'$1' does not exist " >&2
  exit 1
fi