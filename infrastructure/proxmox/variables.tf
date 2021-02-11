

/**
  node-definitions for all members of the cluster
*/
variable "cluster_nodes" {
  default = {}
  type = map(list(object({
    ip = string
    host = string
    name = string
    clone = string
    description = string
    full_clone = bool

    hardware_configuration = object({
      cpu = number
      disk = number
      sockets = number
      memory = number
      boot_disk = string
    })
  })))
}
