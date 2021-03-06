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
  api_dns = var.api_server
  api_domain = var.domain
  api_ip = var.load_balancer
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
  depends_on = [
    module.virtual_machines]
  source = "./etcd"
  load_balancer = var.load_balancer
  domain = var.domain
  k8s_leaders = var.cluster_nodes["k8s_leaders"]
  virtual_machine_configuration = var.virtual_machine_configuration
  etcd_cluster = module.virtual_machines["etcd_nodes"].virtual_machines
}


module "k8s_cluster_base" {
  depends_on = [
    module.etcd_cluster]
  source = "./k8s/base"
  //  for_each = {for key, vms in module.virtual_machines: key => vms}
  //
  //  k8s_cluster =

  etcd_port = var.etcd_port
  load_balancer = "${var.api_dns}.${var.domain}"
  //  load_balancer = var.load_balancer
  virtual_machine_configuration = var.virtual_machine_configuration
  k8s_cluster = concat(
  values(module.virtual_machines["etcd_nodes"].virtual_machines),
  values(module.virtual_machines["k8s_leaders"].virtual_machines),
  values(module.virtual_machines["k8s_workers"].virtual_machines),
  )

  k8s_workers = values(module.virtual_machines["k8s_workers"].virtual_machines)
  k8s_leaders = values(module.virtual_machines["k8s_leaders"].virtual_machines)
  etcd_cluster = values(module.virtual_machines["etcd_nodes"].virtual_machines)
}

module "k8s_cluster_workers" {
  depends_on = [
    module.k8s_cluster_base]
  source = "./k8s/workers"
  worker_domain = var.domain
  ceph_config = var.ceph_config
  worker_auth = var.virtual_machine_configuration
  workers = var.cluster_nodes["k8s_workers"]
}