
resource "null_resource" "etcd_cluster" {
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