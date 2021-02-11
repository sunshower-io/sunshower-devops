
variable "dns_server" {
  type = object({
    zone = string
    server = string
  })
}

variable "hosts" {
  default = []
  type = list(object({
    ip = string
    host = string
    name = string
    clone = string
    full_clone = bool
    description = string
    hardware_configuration = object({
      cpu = number
      disk = number
      sockets = number
      memory = number
      boot_disk = string
    })
  }))
}