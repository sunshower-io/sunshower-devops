
module "etcd_machines" {
  source = "./vms"
  domain = var.domain
  cluster_configuration = var.cluster_configuration
  virtual_machine_configuration = var.virtual_machine_configuration
  virtual_machines = var.cluster_nodes['etcd_nodes']
}