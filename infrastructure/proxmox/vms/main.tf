
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

/**
  create all virtual machines in the cluster

  subsequent modules will configure the virtual
  machines based on their roles
*/
resource "proxmox_vm_qemu" "virtual_machines" {
  for_each = {for vm in var.virtual_machines: vm.name => vm}

  agent = 1
  name = each.key
  clone = "debian-base"
  target_node = each.value.host
}

