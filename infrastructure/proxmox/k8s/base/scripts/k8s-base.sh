#!/usr/bin/env bash
# install docker on all nodes
apt-get update

function install_pkg() {
  local pkg_name=$1
  echo "Attempting to install packages: $pkg_name..."

  until apt-get install -y "$pkg_name"
  do
    echo "Failed to retrieve packages...retrying"
    sleep 5
  done

  echo "successfully installed packages: $pkg_name"
}

install_pkg "curl"
install_pkg "gnupg2"
install_pkg "ca-certificates"
install_pkg "apt-transport-https"
install_pkg "software-properties-common"


curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

apt-add-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable"

apt-get update
install_pkg "docker-ce"

docker -v


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
install_pkg "kubelet"
install_pkg "kubeadm"
install_pkg "kubectl"
#apt-get install -y kubelet kubeadm kubectl

apt-mark hold kubelet kubeadm kubectl

