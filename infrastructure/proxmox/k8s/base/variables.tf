variable "k8s_cluster" {
  type = list(object({
    name = string
    # due to ugly hack, contains IP
    desc = string
    ssh_port = string
    ssh_host = string
  }))
}


variable "k8s_workers" {
  type = list(object({
    name = string
    # due to ugly hack, contains IP
    desc = string
    ssh_port = string
    ssh_host = string
  }))
}

variable "k8s_leaders" {
  type = list(object({
    name = string
    # due to ugly hack, contains IP
    desc = string
    ssh_port = string
    ssh_host = string
  }))
}

variable "etcd_cluster" {
  type = list(object({
    name = string
    desc = string
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

variable "load_balancer" {
  type = string
}

variable "etcd_port" {
  type = number
  default = 2379
}
