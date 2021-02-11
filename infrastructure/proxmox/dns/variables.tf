
variable "dns_server" {
  type = object({
    zone = string
    server = string
  })
}