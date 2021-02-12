variable "k8s_cluster" {
  type = list(object({
    name = string
    ssh_port = string
    ssh_host = string
  }))
}

variable "etcd_cluster" {
  type = list(object({
    name = string
    ssh_port = string
    ssh_host = string
  }))
}

variable "virtual_machine_configuration" {
  type = object({
    username = string
    password = string
  })
}
