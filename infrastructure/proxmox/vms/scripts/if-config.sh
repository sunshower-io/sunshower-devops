#!/usr/bin/env bash
# To invoke:
# write_file "$ip" "$gateway" "$netmask" "$dnsservers"
# example:
# write_file "192.168.1.2" "192.168.1.2" "255.255.255.0" "192.168.1.1 8.8.8.8"
function write_file() {
  local ip=$1
  local gateway=$2
  local netmask=$3
  local dnsservers=$4
  cat <<-EOF > /etc/network/interfaces

  source /etc/network/interfaces.d/*

  iface ens18 inet static
    address $ip/24
    gateway $gateway
    network $netmask
    dns-nameservers $dnsservers
EOF
}

write_file "$1" "$2" "$3" "$4"
sed -i.bak 's/^  //g' /etc/network/interfaces