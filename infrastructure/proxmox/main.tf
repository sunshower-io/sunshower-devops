

terraform {
  required_version = ">=0.14"
  required_providers {
    dns = {
      source = "hashicorp/dns"
      version = "3.0.1"
    }
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.6.7"
    }
  }
}

provider "dns" {
  update {
    server = var.dns_server.server
  }
}

provider "proxmox" {
  pm_api_url = var.cluster_configuration.url
  pm_user = var.cluster_configuration.username
  pm_password = var.cluster_configuration.password
  pm_tls_insecure = !var.cluster_configuration.verify_tls
}


/**
  Create DNS entries for virtual machines
*/
module "dns_configuration" {
  for_each = var.cluster_nodes
  source = "./dns"
  dns_server = var.dns_server
  hosts = each.value
}

/**
  provision virtual machines
*/
module "virtual_machines" {
  for_each = var.cluster_nodes
  source = "./vms"
  domain = var.domain
  virtual_machines = each.value
  network_configuration = var.network_configuration
  cluster_configuration = var.cluster_configuration
  virtual_machine_configuration = var.virtual_machine_configuration
}


module "etcd_cluster" {
  source = "./etcd"
  load_balancer = var.load_balancer
  k8s_leaders = var.cluster_nodes["k8s_leaders"]
  etcd_cluster = module.virtual_machines["etcd_nodes"].virtual_machines
  virtual_machine_configuration = var.virtual_machine_configuration
}