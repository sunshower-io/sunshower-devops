
# install docker on all nodes
apt-get update

apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg2 \
  software-properties-common


curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

apt-add-repository \
  "deb [arch=amd64] https://download.docker.com/linux/debian \
  $(lsb_release -cs) \
  stable"

apt-get update && apt-get -y install docker-ce

docker -v


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update && apt-get install -y kubelet kubeadm kubectl

apt-mark hold kubelet kubeadm kubectl

swapoff -a

sed -i '/ swap / s/^/#/' /etc/fstab