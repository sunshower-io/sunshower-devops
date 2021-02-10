//output "etcd_machines" {
//  value = proxmox_vm_qemu.etcd_machines
//}

output "etcd_dns_entries" {
  value = windns.etcd_dns_configurations
}