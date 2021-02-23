variable "domain" {
  type = string
}


variable "network_configuration" {
  type = object({
    gateway = string
    netmask = string
    nameservers = list(string)
  })
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
    hosts = map(string)
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
    pool = string
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
  }))
}



