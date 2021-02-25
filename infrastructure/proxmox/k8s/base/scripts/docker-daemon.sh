#!/usr/bin/env bash
cat <<-EOF > /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF
sudo systemctl restart docker


until [ "$(systemctl is-active docker)" = 'active' ]; do

  echo "waiting for docker daemon to start..."
  sleep 1
done

echo "Docker started.  Logging in"
# todo: add docker login --username <username> password <password>
echo "Logged in"
