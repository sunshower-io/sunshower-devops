locals {
  etcd1 = var.etcd_cluster[0]
  leader_1 = var.k8s_leaders[0]
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

  provisioner "remote-exec" {
    script = "${path.module}/scripts/docker-daemon.sh"
  }
}

resource "null_resource" "k8s_leader_base" {
  depends_on = [
    null_resource.base_configuration]

  count = length(var.k8s_leaders)

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = var.k8s_leaders[count.index].desc
    port = var.k8s_leaders[count.index].ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /etc/kubernetes/pki/etcd"
    ]
  }
}

resource "null_resource" "etcd_nodes" {

  count = length(var.etcd_cluster)
  depends_on = [
    null_resource.base_configuration]

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
    null_resource.etcd_nodes,
    null_resource.base_configuration]

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

  provisioner "file" {
    source = "${path.module}/scripts/k8s-leader.sh"
    destination = "/tmp/k8s-leader.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s-leader.sh",
      "chmod +x /tmp/etcd-bastion.sh",
      "/tmp/etcd-bastion.sh '${local.authentication.password}' ${join(" ", local.etcd_cluster_ips)}",
      "/tmp/k8s-leader.sh provision_leader_certs ${local.leader_1.desc} '${local.authentication.password}'"
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

resource "null_resource" "k8s_leader_1" {
  depends_on = [
    null_resource.config_other_etcd_cluster_nodes]

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = local.leader_1.name
    port = local.leader_1.ssh_port
  }

  provisioner "file" {
    source = "${path.module}/scripts/k8s-leader.sh"
    destination = "/tmp/k8s-leader.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k8s-leader.sh",
      "/tmp/k8s-leader.sh create_leader_cfg ${var.load_balancer} ${var.etcd_port} ${join(" ", local.etcd_cluster_ips)}"
    ]
  }

}

resource "null_resource" "download_configs" {

  depends_on = [
    null_resource.k8s_leader_1,
    null_resource.k8s_leader_base]

  provisioner "local-exec" {
      command = "${path.module}/scripts/download-configs.sh '${local.authentication.password}' ${local.leader_1.name}"
  }

}

resource "null_resource" "copy_k8s_configs" {

  depends_on = [
    null_resource.download_configs]

  for_each = {for vm in slice(var.k8s_leaders, 1, length(var.k8s_leaders)): vm.name => vm}

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = local.leader_1.name
    port = local.leader_1.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "/tmp/k8s-leader.sh configure_second_leader ${each.value.name} ${local.authentication.username} ${local.authentication.password}"
    ]
  }
}


resource "null_resource" "copy_k8s_worker_configs" {

  depends_on = [
    null_resource.download_configs]

  for_each = {for vm in var.k8s_workers: vm.name => vm}

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = local.leader_1.name
    port = local.leader_1.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "/tmp/k8s-leader.sh configure_worker ${each.value.name} ${local.authentication.username} ${local.authentication.password}"
    ]
  }
}

resource "null_resource" "k8s_leaders_join_cluster" {
  depends_on = [
    null_resource.copy_k8s_configs]
  for_each = {for vm in slice(var.k8s_leaders, 1, length(var.k8s_leaders)): vm.name => vm}

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = each.value.name
    port = each.value.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/join-leader.sh",
      "sh /tmp/join-leader.sh"
    ]
  }
}

resource "null_resource" "k8s_workers_join_cluster" {
  depends_on = [
    null_resource.copy_k8s_configs]

  for_each = {for vm in var.k8s_workers: vm.name => vm}

  connection {
    type = "ssh"
    user = local.authentication.username
    password = local.authentication.password

    host = each.value.name
    port = each.value.ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/join.sh",
      "sh /tmp/join.sh"
    ]
  }
}