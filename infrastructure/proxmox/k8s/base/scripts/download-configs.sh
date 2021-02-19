#!/usr/bin/env bash

function copy_remote_id() {
  ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa2 <<<y 2>&1 >/dev/null
  local leader_1=$2
  local local_password=$1
  sshpass -p "$local_password" ssh-copy-id -i ~/.ssh/id_rsa2.pub -o StrictHostKeyChecking=no "root@$leader_1"
}


function copy_files() {
  local leader_1=$2
  local local_password=$1
  sshpass -p "$local_password" scp "root@$leader_1:/tmp/join.sh" "/tmp/join.sh"
  sshpass -p "$local_password" scp "root@$leader_1:/etc/kubernetes/admin.conf" "/tmp/kubernetes-config.yaml"
  sshpass -p "$local_password" scp -r "root@$leader_1:/etc/kubernetes/pki" "/tmp/"
}

copy_remote_id "$1" "$2"

copy_files "$1" "$2"
