terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.7"
    }

    windns = {
      source = "PortOfPortland/windns"
      version = "0.5.1"
    }
  }
}

provider "proxmox" {
  pm_user = var.cluster_username
  pm_api_url = var.cluster_url
  pm_password = var.cluster_password
  pm_tls_insecure = var.cluster_no_verify_tls
}


provider "windns" {
  usessl = var.dns_server_configuration.ssl
  server = var.dns_server_configuration.host
  username = var.dns_server_configuration.username
  password = var.dns_server_configuration.password
}


resource "proxmox_vm_qemu" "etcd_machines" {
  count = length(var.etcd_machines)

  /**
  VM configuration
  */

  /**
  enable QEMU agent
  */
  agent = 1

  /**
  number of cores--could be made configurable
  */
  cores = 2

  /**
  number of physical sockets
  */
  sockets = 1

  /**
  Memory in MB
  */
  memory = 2048

  /**
  use the clone disk as the boot disk
  */
  bootdisk = "scsi0"


  full_clone = false
  clone = "debian-base"

  desc = "etcd${count.index} node"
  pool = "kubernetes-infrastructure"

  searchdomain = var.deployment_domain
  target_node = var.etcd_machines[count.index].host
  name = "${var.etcd_machines[count.index].name}.${var.deployment_domain}"



  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  /**
  these configuration parameters seem to be required and set to
  these values in order to get the self.ssh_host value populated
  */
  os_type = "cloud-init"
  ipconfig0 = "ip=${var.etcd_machines[count.index].ip}/24,gw=192.168.1.1"

  /**
  the network configuration to use
  */
  os_network_config = <<EOF
  iface vmbr0 inet static
    address ${var.etcd_machines[count.index].ip}
    gateway 192.168.1.1
    netmask 255.255.255.0
  EOF

  connection {
    type = "ssh"
    port = 22
    host = self.ssh_host
    user = var.root_username
    password = var.root_password
  }

  provisioner "remote-exec" {
    inline = [
      "ip a",
      <<-EOF
        cat <<EOF2 > /etc/network/interfaces
          source /etc/network/interfaces.d/*
          iface vmbr0 inet static
            address ${var.etcd_machines[count.index].ip}
            gateway 192.168.1.1
            netmask 255.255.255.0
        EOF2
      EOF
    ,
      <<-EOF
      sed -i.bak "s/^  //g" /etc/network/interfaces
      EOF
    ]
  }
}

resource "null_resource" "wait_for_reboot" {
  count = length(proxmox_vm_qemu.etcd_machines)
  depends_on = [
    null_resource.set_hostname,
    proxmox_vm_qemu.etcd_machines]

  provisioner "local-exec" {
    command = "${path.module}/wait_port ${var.etcd_machines[count.index].name} 22"
  }
}


resource "null_resource" "set_hostname" {
  count = length(proxmox_vm_qemu.etcd_machines)
  depends_on = [
    proxmox_vm_qemu.etcd_machines]

  connection {
    type = "ssh"
    user = var.root_username
    password = var.root_password
    host = proxmox_vm_qemu.etcd_machines[count.index].ssh_host
    port = proxmox_vm_qemu.etcd_machines[count.index].ssh_port
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${var.root_password} | sudo -S -k hostnamectl set-hostname ${var.etcd_machines[count.index].name}.${var.deployment_domain}",
      "echo ${var.root_password} | (sleep 2 && sudo -S -k reboot)&"
    ]
  }


}


resource "windns" "etcd_dns_configurations" {
  count = length(proxmox_vm_qemu.etcd_machines)
  zone_name = var.deployment_domain
  record_type = "A"
  record_name = proxmox_vm_qemu.etcd_machines[count.index].name
  ipv4address = proxmox_vm_qemu.etcd_machines[count.index].ssh_host

  //  depends_on = [
  //    null_resource.wait_for_reboot]
}