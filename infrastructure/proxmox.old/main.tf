
module "etcd_machines_base" {
  source = "./virtual-machines"

  /**
    cluster configuration
  */
  cluster_url = var.cluster_url
  cluster_username = var.cluster_username
  cluster_password = var.cluster_password
  cluster_no_verify_tls = var.cluster_no_verify_tls


  virtual_machines = var.etcd_machines
  deployment_domain = var.deployment_domain

  /**
  virtual machine configuration
  */
  root_password = var.root_password
  root_username = var.root_username
  dns_server_configuration = var.dns_server_configuration

}

module "etcd_machines_installation" {
  source = "./etcd"
  connection_info = {
    username = var.root_username
    password = var.root_password
  }
  etcd_port = var.etcd_port
  load_balancer = var.load_balancer

  etcd_machines = module.etcd_machines_base.virtual_machines

  /**
    select the first two etcd machines for the load-balancer components
  */
  k8s_leaders = var.k8s_leaders
  load_balancer_members = slice(module.etcd_machines_base.virtual_machines, 0, 2)
}


