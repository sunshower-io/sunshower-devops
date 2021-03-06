terraform {
  required_providers {
    dns = {
      source = "hashicorp/dns"
    }
  }
}


/**
  provision DNS entries for each host in the `hosts` list
*/
resource "dns_a_record_set" "virtual_machine_dns" {
  for_each = {for vm in var.hosts: vm.name => vm}

  zone = var.dns_server.zone
  name = each.value.name
  addresses = [
    each.value.ip
  ]
}


/**
  provision the DNS A-record for the API server
*/
resource "dns_a_record_set" "api_server_dns" {
  addresses = [
    var.api_ip
  ]
  zone = var.dns_server.zone
  name = var.api_dns
}