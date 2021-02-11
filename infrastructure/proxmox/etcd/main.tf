/**
  Generate a strong random password for the heartbeat daemons.
  This is included in the outputs
*/
resource "random_password" "heartbeat_password" {
  length = 24
  special = true
}


/**
  install basic configuration, dependencies, and firewall rules for etcd
*/
resource "null_resource" "base_configuration" {
  count = length(var.etcd_machines)

  connection {
    type = "ssh"
    user = var.connection_info.username
    password = var.connection_info.password
    host = var.etcd_machines[count.index].ssh_host
    port = var.etcd_machines[count.index].ssh_port
  }

  provisioner "remote-exec" {
    script = "${path.module}/base.sh"
  }
}

/**
  configure etcd on each node
*/
resource "null_resource" "etcd_configuration" {
  count = length(var.load_balancer_members)

  depends_on = [
    null_resource.base_configuration]

  connection {
    type = "ssh"
    user = var.connection_info.username
    password = var.connection_info.password
    host = var.etcd_machines[count.index].ssh_host
    port = var.etcd_machines[count.index].ssh_port
  }

  provisioner "file" {
    source = "${path.module}/haproxy.sh"
    destination = "/tmp/haproxy.sh"
  }

  provisioner "file" {
    source = "${path.module}/ha-config.sh"
    destination = "/tmp/ha-config.sh"
  }

  provisioner "remote-exec" {
    inline = [

      /**
        install haproxy and heartbeat
      */
      "apt-get install -y haproxy heartbeat",


      /**
        copy haproxy and ha-config (heartbeat configuration) to node
      */
      "chmod +x /tmp/haproxy.sh",
      "chmod +x /tmp/ha-config.sh",

      /**
        generate haproxy configuration pointing each HA node at
        the other
      */
      <<-EOF
      /tmp/haproxy.sh \
            ${var.load_balancer}:${var.etcd_port} \
            ${var.k8s_leaders[0].name} \
            ${var.k8s_leaders[0].ip}:${var.etcd_port} \
            ${var.k8s_leaders[1].name} \
            ${var.k8s_leaders[1].ip}:${var.etcd_port}
      EOF
    ,
      /**
        The heredoc format inserts leading whitespace into the config
        file--trim it off
      */
      "sed -i 's/^    //g' /etc/haproxy/haproxy.cfg",


      /**
        Start HA proxy
      */
      "sudo systemctl start haproxy",

      /**
        Allow haproxy node interfaces to bind to non-local IP address
      */
      "echo 'net.ipv4.ip_nonlocal_bind=1' >> /etc/sysctl.conf",

      /**
        reload kernel parameters without forcing a restart
      */
      "sysctl -p",

      /**
        restart HAproxy with the new non-local IP bindings
      */
      "sudo systemctl restart haproxy",


      /**
        print debugging information
      */
      "netstat -ntlp",

      /**
        enable the heartbeat daemon
      */
      "sudo systemctl enable heartbeat",

      /**
        configure the heartbeat daemon, including auth between nodes
      */
      <<-EOF
        cat <<EOF2 > /etc/ha.d/authkeys
          auth 1
          1 md5 ${md5(random_password.heartbeat_password.result)}
        EOF2
      EOF
    ,
      /**
        another heredoc formatting issues
      */
      "sed -i.bak 's/^  //g' /etc/ha.d/authkeys",

      /**
        ensure that only root can access the authkeys
        for the heartbeat daemon
      */
      "chmod 600 /etc/ha.d/authkeys",

      /**
        point each HAProxy at the other node.  We could (possibly)
        configure this to be parameterized by the network interface
        which would allow for provisioning multiple network interfaces
        in proxmox, but we don't need that for now
      */
      <<-EOF
        /tmp/ha-config.sh \
          ${var.load_balancer_members[(count.index + 1) % length(var.load_balancer_members)].ssh_host} \
          ${var.load_balancer_members[0].name} \
          ${var.load_balancer_members[1].name}
        EOF
    ,

      /**
        trim leading whitespace from HEREDOC-generated
        file
      */
      "sed -i 's/^    //g' /etc/ha.d/ha.cf",
      /**
        Select the leader for the load-balancer (first HA node, by default)
      */
      "echo '${var.load_balancer_members[0].name} ${var.load_balancer}' >> /etc/ha.d/haresources",
      /**
        Restart the heartbeat daemon
      */
      "systemctl restart heartbeat",

      /**
        print configurations
      */
      "ip a"
    ]
  }

}
