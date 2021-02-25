/**
  On ceph host:

  rbd create <size in mb> --image-feature layering,exclusive-lock <pool>/<volume>

  rbd create --size 524288 --image-feature layering,exclusive-lock rbd/devops
  ceph auth get-or-create client.fs
  ceph config generate-minimal-conf

*/
variable "ceph_config" {
  type = object({
    key = string
    /**
      ID of the filesystem
    */
    fs_id = string
    host = string
  })
}

variable "worker_domain" {
  type = string
  default = ""
}

variable "worker_auth" {
  type = object({
    username = string
    password = string
  })
  default = null
}

variable "workers" {
  type = list(object({
    name = string
  }))
  default = []
}


