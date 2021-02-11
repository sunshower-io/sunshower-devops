/**
  The etcd machines to create--passed in to "virtual_machines"
*/
variable "etcd_machines" {
  default = []
  type = list(
  object({
    name = string
    ip = string
    host = string
    cpu = number
    disk = number
    memory = number
    sockets = number
  }))
}

variable "k8s_leaders" {
  default = []
  type = list(object({
    ip = string
    name = string
  }))
}

variable "load_balancer" {
  type = string
}

variable "etcd_port" {
  type = number
  default = 6443
}
