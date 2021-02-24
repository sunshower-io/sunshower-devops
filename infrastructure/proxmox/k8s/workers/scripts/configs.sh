#!/usr/bin/env bash
until apt-get install -y ceph-common
do
  echo "Failed to retrieve ceph-common.  Retrying"
  sleep 5
done
echo "Successfully installed ceph-common"

echo "Creating ceph.conf..."
cat <<-EOF > /etc/ceph/ceph.conf
[global]
        fsid = fb74f791-7a11-49de-9c4c-5d38dcdd2021
        mon_host = [v2:192.168.1.4:3300/0,v1:192.168.1.4:6789/0]
EOF
echo "Successfully created ceph.conf"


echo "Installing ceph keyring..."
cat <<-EOF /etc/ceph/ceph.keyring
[client.fs]
        key = AQDKpzZgRSbgMBAA2Qd3YBc8t6Is1UyxKuUjXw==
EOF
echo "Successfully installed ceph keyring"




