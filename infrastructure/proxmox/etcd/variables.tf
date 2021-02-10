variable "etcd_machines" {
  default = []
  type = list(object({
    ssh_port = number
    ssh_host = string
  }))
}

variable "connection_info" {
  type = object({
    username = string
    password = string
  })
}

