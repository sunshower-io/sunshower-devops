#!/usr/bin/env bash


function write_ha_cfg() {
  local unicast_ip=$1
  local host1=$2
  local host2=$3

  echo "Configuring HA proxy $unicast_ip: $host1 <-> $host2"

  cat << EOF > /etc/ha.d/ha.cf
    keepalive 2
    deadtime 10
    udpport        694
    bcast ens18
    mcast ens18 225.0.0.1 694 1 0
    ucast ens18 $unicast_ip
    udp     ens18
    logfacility     local0
    node    $host1
    node    $host2
EOF

}

write_ha_cfg "$1" "$2" "$3"
sed -i 's/^    //g' /etc/ha.d/ha.cf
