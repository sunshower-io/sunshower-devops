

terraform {
  required_version = ">=0.14"
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

module "virtual_machines" {
  for_each = var.cluster_nodes
  source = "./vms"
  domain = var.domain
  virtual_machines = each.value
  cluster_configuration = var.cluster_configuration
  virtual_machine_configuration = var.virtual_machine_configuration
}