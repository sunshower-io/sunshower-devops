
/**
  the domain suffix for your DNS entries (e.g. `sunshower.io`)
*/
variable "api_domain" {
  type = string
}

/**
  the Kubernetes load-balancer IP address
*/
variable "api_ip" {
  type = string
}

/**
  the short-name (e.g. `kubernetes`) for your kubernetes API server.
  There isn't a single, physical server hosting this in a HA configuration.
  Instead, we configure a HAProxy load-balancer with this IP which is
  shared by the load-balancer backend nodes
*/
variable "api_dns" {
  type = string
}

/**
  DNS server configuration
*/
variable "dns_server" {
  type = object({
    zone = string
    server = string
  })
}


/**
  a list of hosts to provision.  Shared between this module
  and the VM module
*/
variable "hosts" {
  default = []
  type = list(object({
    ip = string
    host = string
    name = string
  }))
}