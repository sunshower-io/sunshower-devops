resource "random_password" "heartbeat_password" {
  length = 24
  special = true
}


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
      "apt-get install -y haproxy heartbeat",
      "chmod +x /tmp/haproxy.sh",
      "chmod +x /tmp/ha-config.sh",
      <<-EOF
      /tmp/haproxy.sh \
            ${var.load_balancer}:${var.etcd_port} \
            ${var.k8s_leaders[0].name} \
            ${var.k8s_leaders[0].ip}:${var.etcd_port} \
            ${var.k8s_leaders[1].name} \
            ${var.k8s_leaders[1].ip}:${var.etcd_port}
      EOF
    ,
      "sudo systemctl start haproxy",
      "sed -i 's/^    //g' /etc/haproxy/haproxy.cfg",
      "echo 'net.ipv4.ip_nonlocal_bind=1' >> /etc/sysctl.conf",
      "sysctl -p",
      "sudo systemctl restart haproxy",
      "netstat -ntlp",
      "sudo systemctl enable heartbeat",
      <<-EOF
        cat <<EOF2 > /etc/ha.d/authkeys
          auth 1
          1 md5 ${md5(random_password.heartbeat_password.result)}
        EOF2
      EOF
    ,
      "sed -i.bak 's/^  //g' /etc/ha.d/authkeys",
      "chmod 600 /etc/ha.d/authkeys",
      //      <<-EOF
      //      /tmp/ha-config.sh \
      //        ${var.load_balancer_members[(count.index + 1) % length(var.leaders)].ssh_host} \
      //        ${var.k8s_leaders[0].name)[0]} \
      //        ${split(".", var.leaders[1].name)[0]}
      //      EOF
      //    ,
      //      "sed -i 's/^    //g' /etc/ha.d/ha.cf",
    ]
  }

}
