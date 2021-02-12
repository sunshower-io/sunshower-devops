locals {
  etcd1 = var.etcd_cluster[0]
  authentication = var.virtual_machine_configuration
  etcd_cluster_ips = [for etcd_node in var.etcd_cluster: etcd_node.ssh_host]
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


resource "null_resource" "etcd_configuration" {
  depends_on = [
    null_resource.base_configuration]

  count = length(var.etcd_cluster)

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = var.etcd_cluster[count.index].ssh_host
    port = var.etcd_cluster[count.index].ssh_port
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/etcd-cluster.sh"
  }
}

resource "null_resource" "etcd_bastion" {
  depends_on = [
    null_resource.etcd_configuration]

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = local.etcd1.ssh_host
    port = local.etcd1.ssh_port
  }

  provisioner "file" {
    source = "${path.module}/scripts/etcd-bastion.sh"
    destination = "/tmp/etcd-bastion.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/etcd-bastion.sh",
      "/tmp/etcd-bastion.sh ${join(" ", local.etcd_cluster_ips)}"
    ]
  }
}