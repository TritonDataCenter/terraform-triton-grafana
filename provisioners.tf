resource "null_resource" "grafana_install" {
  count = "${var.provision == "true" ? "1" : 0}"

  triggers {
    machine_ids = "${triton_machine.grafana.*.id[count.index]}"
  }

  connection {
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.bastion_user}"
    bastion_private_key = "${file(var.private_key_path)}"

    host        = "${triton_machine.grafana.*.primaryip[count.index]}"
    user        = "${var.user}"
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/grafana_installer/",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/packer/scripts/install_grafana.sh"
    destination = "/tmp/grafana_installer/install_grafana.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 0755 /tmp/grafana_installer/install_grafana.sh",
      "sudo /tmp/grafana_installer/install_grafana.sh",
    ]
  }

  # clean up
  provisioner "remote-exec" {
    inline = [
      "rm -rf /tmp/grafana_installer/",
    ]
  }
}
