
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
