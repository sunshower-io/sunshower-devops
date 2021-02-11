terraform {
  required_providers {
    dns = {
      source = "hashicorp/dns"
    }
  }
}


resource "dns_a_record_set" "virtual_machine_dns" {
  for_each = {for vm in var.virtual_machines: vm.name => vm}

  zone = "sunshower.io."
  name = each.value.name
  addresses = [
    each.value.ip
  ]
}
