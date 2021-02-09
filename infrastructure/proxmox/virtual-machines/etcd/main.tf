
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.7"
    }
  }
}

provider "proxmox" {
  pm_user = var.cluster_username
  pm_api_url = var.cluster_url
  pm_password = var.cluster_password
  pm_tls_insecure = var.cluster_no_verify_tls
}


resource "proxmox_vm_qemu" "etcd1" {
  count = length(var.etcd_machines)

  name = "${var.etcd_machines[count.index].name}.${var.deployment_domain}"
  desc = "first etcd node"
  pool = "kubernetes-infrastructure"
  target_node = var.etcd_machines[count.index].host
  clone = "debian-base"
  full_clone = false

  agent = 1

  cores = 2
  sockets = 1
  memory = 2048
  bootdisk = "scsi0"


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
  os_network_config = <<EOF
  iface vmbr0 inet static
    address 192.168.1.10
    gateway 192.168.1.1
    netmask 255.255.255.0
  EOF

  connection {
    type = "ssh"
    user = var.root_username
    password = var.root_password

    host = self.ssh_host
    port = 22
  }

  provisioner "remote-exec" {
    inline = [
      "ip a"
    ]
  }
}
