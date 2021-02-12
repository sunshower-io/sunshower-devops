variable "etcd_port" {
  type = number
  default = 6443
}

variable "load_balancer" {
  type = string
}
variable "virtual_machine_configuration" {
  type = object({
    username = string
    password = string
  })
}

variable "etcd_cluster" {
  type = map(object({
    name = string
    ssh_port = string
    ssh_host = string
  }))
}

variable "k8s_leaders" {
  type = list(object({
    ip = string
    name = string
  }))
}
