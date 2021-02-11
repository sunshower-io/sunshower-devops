output "virtual_machines" {
  value = proxmox_vm_qemu.virtual_machines
}

output "dns_entries" {
  value = windns.dns_entries
}