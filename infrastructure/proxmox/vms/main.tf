
terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.7"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.cluster_configuration.url
  pm_user = var.cluster_configuration.username
  pm_password = var.cluster_configuration.password
  pm_tls_insecure = !var.cluster_configuration.verify_tls
}


resource "proxmox_vm_qemu" "virtual_machines" {
  count = length(var.virtual_machines)

  agent = 1

}