variable "domain" {
  type = string
}

/**
  configuration variable to store Proxmox cluster configuration in
*/
variable "cluster_configuration" {
  type = object({
    url = string
    username = string
    password = string
    verify_tls = bool
  })
}

variable "virtual_machine_configuration" {
  type = object({
    username = string
    password = string
  })
}


variable "virtual_machines" {
  default = []
  type = list(object({
    ip = string
    host = string
    name = string
    hardware_configuration = object({
      cpu = number
      disk = number
      sockets = number
      memory = number
    })
  }))
}


