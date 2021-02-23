#!/usr/bin/env bash

echo "Provisioning etcd cluster on $(uname -a)"
cat << EOF > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
#  Replace "systemd" with the cgroup driver of your container runtime. The default value in the kubelet is "cgroupfs".
ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=systemd
Restart=always
EOF



systemctl daemon-reload
systemctl restart kubelet
echo "Completed provisioning etcd cluster on $(uname -a)"
