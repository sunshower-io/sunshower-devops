/**
provision ceph on workers
*/
resource "null_resource" "ceph_worker_configuration" {

  for_each = {for worker in var.workers: "${worker.name}.${var.worker_domain}" => worker}
  connection {
    type = "ssh"
    host = each.key
    user = var.worker_auth.username
    password = var.worker_auth.password
  }

  provisioner "file" {
    source = "${path.module}/scripts/worker-ceph-configs.sh"
    destination = "/tmp/worker-ceph-configs.sh"
  }

  provisioner "remote-exec" {
    script = "${path.module}/scripts/install-ceph-common.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/worker-ceph-configs.sh",
      "/tmp/worker-ceph-configs.sh install_keyring '${var.ceph_config.key}'",
      "/tmp/worker-ceph-configs.sh generate_ceph_conf '${var.ceph_config.host}' '${var.ceph_config.fs_id}'"
    ]
  }

}