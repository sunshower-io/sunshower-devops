#!/usr/bin/env bash
until apt-get install -y ceph-common
do
  echo "Failed to retrieve ceph-common.  Retrying"
  sleep 5
done
echo "Successfully installed ceph-common"

function check_dir() {
  if [ -d "/etc/ceph" ]
  then
    echo "/etc/ceph exists--not doing anything"
  else
    echo "Directory /etc/ceph/ does not exist--attempting to create"
    mkdir -p /etc/ceph
  fi
}


function generate_ceph_conf() {
  check_dir
  local host=$1
  local fs_id=$2
  echo "Creating ceph.conf..."
cat <<-EOF > /etc/ceph/ceph.conf
[global]
        fsid = $fs_id
        mon_host = [v2:$host:3300/0,v1:$host:6789/0]
EOF
  echo "Successfully created ceph.conf"
}



# call with ./configs.sh install_keyring $keyring
function install_keyring() {
  check_dir
  echo "Installing ceph keyring..."
  local key=$1
cat <<-EOF > /etc/ceph/ceph.keyring
[client.fs]
        key = $key
EOF
  echo "Successfully installed ceph keyring"
}

if declare -f "$1" > /dev/null
then
  "$@"
else
  echo "'$1' does not exist " >&2
  exit 1
fi


