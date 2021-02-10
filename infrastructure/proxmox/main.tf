
module "etc_vms" {
  source = "./virtual-machines/etcd"

  /**
    cluster configuration
  */
  cluster_url = var.cluster_url
  cluster_username = var.cluster_username
  cluster_password = var.cluster_password
  cluster_no_verify_tls = var.cluster_no_verify_tls


  etcd_machines = var.etcd_machines
  deployment_domain = var.deployment_domain

  /**
  virtual machine configuration
  */
  root_password = var.root_password
  root_username = var.root_username

  dns_server_configuration = var.dns_server_configuration

}



