#!/usr/bin/env bash


function write_ha_proxy_cfg() {
  local loadbalancer=$1

  local leader_1_ip=$3
  local leader_1_name=$2

  local leader_2_ip=$5
  local leader_2_name=$4

#  local leader_1=$2
#  local leader_2=$3

  echo "HA PROXY Configuration: load-balancer: $loadbalancer, leader 1: $leader_1_ip, leader 2: $leader_2_ip"


  mv /etc/haproxy/haproxy.cfg{,.back}

  cat << EOF > /etc/haproxy/haproxy.cfg
    global
        user haproxy
        group haproxy
    defaults
        mode http
        log global
        retries 2
        timeout connect 3000ms
        timeout server 5000ms
        timeout client 5000ms
    frontend kubernetes
        bind $loadbalancer
        option tcplog
        mode tcp
        default_backend kubernetes-master-nodes
    backend kubernetes-master-nodes
        mode tcp
        balance roundrobin
        option tcp-check
        server $leader_1_name $leader_1_ip check fall 3 rise 2
        server $leader_2_name $leader_2_ip check fall 3 rise 2
EOF

}
write_ha_proxy_cfg "$1" "$2" "$3" "$4" "$5"
sed -i 's/^    //g' /etc/haproxy/haproxy.cfg
