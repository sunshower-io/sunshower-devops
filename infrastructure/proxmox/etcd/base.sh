# Allow IPTables to see bridged traffic
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system


# Firewall config

apt-get install firewalld -y

# iptables 1.8.2 fails to reload rules without individual calls
sed -i 's/IndividualCalls=no/IndividualCalls=yes/g' /etc/firewalld/firewalld.conf
firewall-cmd --permanent --add-port=2376/tcp
firewall-cmd --permanent --add-port=2379/tcp
firewall-cmd --permanent --add-port=2380/tcp
firewall-cmd --permanent --add-port=8472/udp
firewall-cmd --permanent --add-port=9099/tcp
firewall-cmd --permanent --add-port=10250/tcp


# Sometimes, even with individual calls, iptables 1.8.2 fails to reload--retry
until [ "$(firewall-cmd --reload)" ]; do
  true
done

