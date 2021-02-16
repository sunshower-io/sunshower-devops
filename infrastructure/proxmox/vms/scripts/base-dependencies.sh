echo "Installing firewalld"

#iptables -F
#iptables -X
#iptables -t nat -F
#iptables -t nat -X
#iptables -t mangle -F
#iptables -t mangle -X
#iptables -P INPUT ACCEPT
#iptables -P OUTPUT ACCEPT
#iptables -P FORWARD ACCEPT
#until apt-get install firewalld -y
#do
#  echo "Apt failed for firewalld--retrying"
#  sleep 5
#done
#sed -i 's/IndividualCalls=no/IndividualCalls=yes/g' /etc/firewalld/firewalld.conf

