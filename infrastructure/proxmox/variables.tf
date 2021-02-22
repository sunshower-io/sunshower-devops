
variable "etcd_port" {
  type = number
  default = 6443
}

variable "load_balancer" {
  type = string
}

variable "api_server" {
  type = string
  default = "api"
}

/**
  node-definitions for all members of the cluster
*/
variable "cluster_nodes" {
  default = {}
  type = map(list(object({
    ip = string
    host = string
    pool = string
    name = string
    clone = string
    full_clone = bool
    description = string
    enable_agent = bool

    os = object({
      type = string
    })

    hardware_configuration = object({
      cpu = number
      disk = number
      sockets = number
      memory = number
      boot_disk = string
    })
  })))
}
