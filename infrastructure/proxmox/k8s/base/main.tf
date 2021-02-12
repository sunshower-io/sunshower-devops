
locals {
  authentication = var.virtual_machine_configuration
}

resource "null_resource" "base_configuration" {
  count = length(var.k8s_cluster)

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = var.k8s_cluster[count.index].ssh_host
    port = var.k8s_cluster[count.index].ssh_port
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/k8s-base.sh"
  }
}