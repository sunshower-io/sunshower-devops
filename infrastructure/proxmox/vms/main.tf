terraform {
  required_providers {
    dns = {
      source = "hashicorp/dns"
    }
    proxmox = {
      source = "Telmate/proxmox"
    }
  }
}

locals {
  network = var.network_configuration
  node_cfg = var.virtual_machine_configuration
  nameservers = join(" ", var.network_configuration.nameservers)
}
/**
  create all virtual machines in the cluster

  subsequent modules will configure the virtual
  machines based on their roles
*/
resource "proxmox_vm_qemu" "virtual_machines" {
  for_each = {for vm in var.virtual_machines: "${vm.name}.${var.domain}" => vm}

  /**
    enable the QEMU agent on the virtual-machine
  */
  agent = each.value.enable_agent == true ? 1 : 0

  /**
    concatenation of <name> and <domain>
    e.g. etcd1.sunshower.io
  */
  name = each.key

  /**
    the resource pool to allocate the VM on
  */
  pool = each.value.pool

  /**
    the image to use
  */
  clone = each.value.clone

  /**
    the host to provision the machine on
    (e.g. "calypso" or "athena" or "demeter")
  */
  target_node = each.value.host

  os_type = each.value.os.type

  /**
    fully clone the base image or use a linked clone
  */
  full_clone = each.value.full_clone

  /**
    network configuration
  */
  searchdomain = var.domain


  ipconfig0 = "ip=${each.value.ip}/24,gw=${local.network.gateway}"

  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  bootdisk = each.value.hardware_configuration.boot_disk

  /**
    hardware configurations
  */



  connection {
    type = "ssh"
    port = 22
    host = each.value.ip
    user = local.node_cfg.username
    password = local.node_cfg.password
  }

  provisioner "file" {
    source = "${path.module}/scripts/if-config.sh"
    destination = "/tmp/if-config.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/if-config.sh",
      "/tmp/if-config.sh ${each.value.ip} ${local.network.gateway} ${local.network.netmask} '${local.nameservers}'",
      "echo ${var.cluster_configuration.password} | sudo -S -k hostnamectl set-hostname ${each.value.name}.${var.domain}",
      "echo ${var.cluster_configuration.password} | (sleep 2 && sudo -S -k reboot)&"
    ]
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/wait-port.sh ${each.value.name} ${var.domain} 22"
  }

}

