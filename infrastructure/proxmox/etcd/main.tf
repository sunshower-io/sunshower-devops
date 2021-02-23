/**
  install basic configuration, dependencies, and firewall rules for etcd
*/

locals {
  authentication = var.virtual_machine_configuration
  etcd_cluster_list = values(var.etcd_cluster)
  etcd_nodes = slice(local.etcd_cluster_list, 0, length(local.etcd_cluster_list) - 1)
}

/**
  Generate a strong random password for the heartbeat daemons.
  This is included in the outputs
*/
resource "random_password" "heartbeat_password" {
  length = 24
  special = true
}

resource "null_resource" "firewall_configuration" {

  for_each = {for key, vm in var.etcd_cluster: key => vm}

  connection {
    type = "ssh"

    user = local.authentication.username
    password = local.authentication.password

    host = each.value.name
    port = each.value.ssh_port
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/etcd-base.sh"
  }
}

resource "null_resource" "base_configuration" {
  //  for_each = {for key, vm in var.etcd_cluster: key => vm}

  count = length(local.etcd_nodes)

  depends_on = [
    null_resource.firewall_configuration]


  connection {
    type = "ssh"

    user = local.authentication.username
    password = local.authentication.password

    host = local.etcd_nodes[count.index].name
    port = local.etcd_nodes[count.index].ssh_port
  }


  provisioner "file" {
    source = "${path.module}/scripts/haproxy.sh"
    destination = "/tmp/haproxy.sh"
  }

  provisioner "file" {
    source = "${path.module}/scripts/ha-config.sh"
    destination = "/tmp/ha-config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/haproxy.sh",
      "chmod +x /tmp/ha-config.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOF
      /tmp/haproxy.sh \
            ${var.load_balancer}:${var.etcd_port} \
            ${var.k8s_leaders[0].name} \
            ${var.k8s_leaders[0].ip}:${var.etcd_port} \
            ${var.k8s_leaders[1].name} \
            ${var.k8s_leaders[1].ip}:${var.etcd_port}
      EOF
    ]
  }


  provisioner "remote-exec" {
    inline = [
      "sudo systemctl start haproxy",
      "echo 'net.ipv4.ip_nonlocal_bind=1' >> /etc/sysctl.conf",
      "sysctl -p",
      "sudo systemctl restart haproxy",
      "netstat -ntlp",
      "sudo systemctl enable heartbeat",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOF
        cat <<EOF2 > /etc/ha.d/authkeys
          auth 1
          1 md5 ${md5(random_password.heartbeat_password.result)}
        EOF2
      EOF
    ,
      "sed -i.bak 's/^  //g' /etc/ha.d/authkeys",
      "chmod 600 /etc/ha.d/authkeys",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      <<-EOF
        /tmp/ha-config.sh \
          ${local.etcd_nodes[(count.index + 1) % length(local.etcd_nodes)].desc} \
          ${local.etcd_nodes[0].name} \
          ${local.etcd_nodes[1].name}
        EOF
    ,
      "echo '${local.etcd_nodes[0].name} ${var.load_balancer}' >> /etc/ha.d/haresources",
      "systemctl restart heartbeat",
      "ip a"
    ]
  }
}
