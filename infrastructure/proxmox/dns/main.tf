terraform {
  required_providers {
    dns = {
      source = "hashicorp/dns"
    }
  }
}


resource "dns_a_record_set" "virtual_machine_dns" {
  for_each = {for vm in var.hosts: vm.name => vm}

  zone = var.dns_server.zone
  name = each.value.name
  addresses = [
    each.value.ip
  ]
}
