/**

  The cluster URL.
  Example usage: cluster.auto.tfvars
  https:athena.sunshower.io:8006/api2/json
*/
variable "cluster_url" {
  default = ""
  type = string
  description = "URL of the Proxmox Cluster"
}

/**
  The password for the proxmox cluster.
  These terraform files only support PAM authentication

  example usage: cluster.auto.tfvars
  cluster_password = "this-is-not-a-secure-password!"
*/
variable "cluster_password" {
  default = ""
  type = string
  description = "Password to Proxmox authentication realm (e.g. PAM)"
  sensitive = true
}


/**
  The username for the proxmox cluster.  Should be the root
  user in the PAM realm.

  example usage: cluster.auto.tfvars
  cluster_username = "root"

*/

variable "cluster_username" {
  default = ""
  type = string
}


/**
  determine whether or not to verify the certificate.
  we're using self-signed certificates by default, so
  the default is insecure = true


  example usage: cluster.auto.tfvars
  cluster_no_verify_tls = true
*/

variable "cluster_no_verify_tls" {
  default = true
}


/**
  variable representing the deployment domain
  example usage: cluster.auto.tfvars
  deployment_domain = "sunshower.io"
*/

variable "deployment_domain" {
  default = "sunshower.io"
}


/**
  variable representing the root username as configured when
  creating the base image. default is "root"


  example usage: cluster.auto.tfvars
  root_username = "root"
*/
variable "root_username" {
  default = "root"
}


/**
  variable representing the root username as configured when
  creating the base image. default is "root"

  example usage: cluster.auto.tfvars
  root_password = "root"
*/
variable "root_password" {
  // no defaults
  type = string
  sensitive = true
  description = "Root VM Password"
}


/**
  The virtual machines to create
*/
variable "virtual_machines" {
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


/**
DNS server config
*/

variable "dns_server_configuration" {
  type = object({
    ssl = bool
    host = string
    username = string
    password = string
  })
}
