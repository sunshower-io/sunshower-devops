variable "etcd_machines" {
  default = []
  type = list(object({
    ssh_port = number
    ssh_host = string
  }))
}

variable "load_balancer_members" {
  default = []
  type = list(object({
    name = string
    ssh_port = number
    ssh_host = string
  }))
}

variable "connection_info" {
  default = {
    username = ""
    password = ""
  }
  type = object({
    username = string
    password = string
  })
}

variable "k8s_leaders" {
  default = []
  type = list(object({
    ip = string
    name = string
  }))
}

variable "load_balancer" {
  default = ""
  type = string
}

variable "etcd_port" {
  default = 6443
  type = number
}

