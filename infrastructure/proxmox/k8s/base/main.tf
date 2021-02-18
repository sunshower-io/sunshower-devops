locals {
  etcd1 = var.etcd_cluster[0]
  etcd_joiners = slice(var.etcd_cluster, 1, length(var.etcd_cluster))
  authentication = var.virtual_machine_configuration
  etcd_cluster_ips = [for etcd_node in var.etcd_cluster: etcd_node.desc]
}

resource "null_resource" "base_configuration" {
  count = length(var.k8s_cluster)

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = var.k8s_cluster[count.index].desc
    port = var.k8s_cluster[count.index].ssh_port
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/swap-off.sh"
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

    host = var.etcd_cluster[count.index].desc
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

    host = local.etcd1.name
    port = local.etcd1.ssh_port
  }

  provisioner "file" {
    source = "${path.module}/scripts/etcd-bastion.sh"
    destination = "/tmp/etcd-bastion.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/etcd-bastion.sh",
      "/tmp/etcd-bastion.sh ${join(" ", local.etcd_cluster_ips)} '${local.authentication.password}'"
    ]
  }
}


resource "null_resource" "config_other_etcd_cluster_nodes" {
  count = length(local.etcd_joiners)

  depends_on = [
    null_resource.etcd_bastion]

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = local.etcd_joiners[count.index].name
    port = local.etcd_joiners[count.index].ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "kubeadm init phase etcd local --config=/root/kubeadmcfg.yaml"
    ]
  }


}