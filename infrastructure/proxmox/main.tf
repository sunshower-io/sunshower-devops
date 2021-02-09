
module "etc_vms" {
  source = "./virtual-machines/etcd"

  /**
    cluster configuration
  */
  cluster_url = var.cluster_url
  cluster_username = var.cluster_username
  cluster_password = var.cluster_password
  cluster_no_verify_tls = var.cluster_no_verify_tls


  etcd_machines = var.etcd_machines
  deployment_domain = var.deployment_domain

  /**
  virtual machine configuration
  */
  root_password = var.root_password
  root_username = var.root_username

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