#!/usr/bin/env bash
until apt-get install -y ceph-common
do
  echo "Failed to retrieve ceph-common.  Retrying"
  sleep 5
done
echo "Successfully installed ceph-common"
