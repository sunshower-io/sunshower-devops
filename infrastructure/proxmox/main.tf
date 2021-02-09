terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.7"
    }
  }
}


/**

  The cluster URL.
  Example usage: cluster.auto.tfvars
  https:athena.sunshower.io:8006/api2/json
*/
variable "cluster_url" {
  default = ""
}

/**
  The password for the proxmox cluster.
  These terraform files only support PAM authentication

  example usage: cluster.auto.tfvars
  cluster_password = "this-is-not-a-secure-password!"
*/
variable "cluster_password" {
  default = ""
}


/**
  The username for the proxmox cluster.  Should be the root
  user in the PAM realm.

  example usage: cluster.auto.tfvars
  cluster_username = "root"

*/

variable "cluster_username" {
  default = ""
}


/**
  determine whether or not to verify the certificate.
  we're using self-signed certificates by default, so
  the default is insecure = true


  example usage: cluster.auto.tfvars
  cluster_no_verify_tls = true
*/

variable "cluster_no_verify_tls" {
  default = true
}


/**
  variable representing the deployment domain
  example usage: cluster.auto.tfvars
  deployment_domain = "sunshower.io"
*/

variable "deployment_domain" {
  default = "sunshower.io"
}


/**
  variable representing the root username as configured when
  creating the base image. default is "root"


  example usage: cluster.auto.tfvars
  root_username = "root"
*/
variable "root_username" {
  default = "root"
}


/**
  variable representing the root username as configured when
  creating the base image. default is "root"

  example usage: cluster.auto.tfvars
  root_password = "root"
*/
variable "root_password" {
  // no defaults
}


variable "etcd_machines" {
  type = list(
    object({
      name = string
      ip = string
      host = string
    })
  )

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

//resource "null_resource" "wait_for_reboot" {
//  depends_on = [
//    proxmox_vm_qemu.etcd1]
//
//  provisioner "local-exec" {
//    command = "${path.module}/scripts/wait_port ${proxmox_vm_qemu.etcd1.ssh_host} ${proxmox_vm_qemu.etcd1.ssh_port}"
//    working_dir = path.module
//  }
//}
//
//
//resource "null_resource" "set_hostname" {
//  depends_on = [
//    null_resource.wait_for_reboot]
//
//  connection {
//    type = "ssh"
//    host = proxmox_vm_qemu.etcd1.ssh_host
//    user = proxmox_vm_qemu.etcd1.ssh_user
//    port = proxmox_vm_qemu.etcd1.ssh_port
//  }
//
//  provisioner "remote-exec" {
//    inline = [
//      "echo ${var.root_password} | sudo -S -k hostnamectl set-hostname etcd1",
//      "echo ${var.root_password} | sudo -S -k reboot"
//    ]
//  }
//}