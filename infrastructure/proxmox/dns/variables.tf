
variable "api_domain" {
  type = string
}

variable "api_ip" {
  type = string
}

variable "api_dns" {
  type = string
}

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