#!/usr/bin/env bash
until swapoff -a
do
  echo "failed to turn swap off"
  sleep 5
done

sed -i '/ swap / s/^/#/' /etc/fstab
