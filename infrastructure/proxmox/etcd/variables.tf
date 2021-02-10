
variable "etcd_machines" {
  default = []
  type = list(
  object({
    name = string
    ip = string
    host = string
    cpu = number
    disk = string
    memory = number
    sockets = number
  }))
}
