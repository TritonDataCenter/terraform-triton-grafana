#
# Data Sources
#
data "triton_image" "ubuntu" {
  name        = "ubuntu-16.04"
  type        = "lx-dataset"
  most_recent = true
}

data "triton_network" "public" {
  name = "Joyent-SDC-Public"
}

data "triton_network" "private" {
  name = "My-Fabric-Network"
}

#
# Modules
#
module "bastion" {
  source = "github.com/joyent/terraform-triton-bastion"

  name    = "prometheus-with-provisioning"
  image   = "${data.triton_image.ubuntu.id}"
  package = "g4-general-4G"

  # Public and Private
  networks = [
    "${data.triton_network.public.id}",
    "${data.triton_network.private.id}",
  ]
}

module "prometheus" {
  source = "github.com/joyent/terraform-triton-prometheus?ref=f-initial-commit"

  name    = "prometheus-with-provisioning"
  image   = "${data.triton_image.ubuntu.id}" # note: using the UBUNTU image here
  package = "g4-general-4G"

  # Public and Private
  networks = [
    "${data.triton_network.private.id}",
  ]

  provision        = "true"                    # note: we ARE provisioning as we are NOT using pre-built images.
  private_key_path = "${var.private_key_path}"

  cmon_cert_file_path = "${var.prometheus_cmon_cert_file_path}"
  cmon_key_file_path  = "${var.prometheus_cmon_key_file_path}"

  bastion_host     = "${element(module.bastion.bastion_ip,0)}"
  bastion_user     = "${module.bastion.bastion_user}"
  bastion_role_tag = "${module.bastion.bastion_role_tag}"
}

module "grafana" {
  source = "../../"

  name    = "prometheus-with-provisioning"
  image   = "${data.triton_image.ubuntu.id}" # note: using the UBUNTU image here
  package = "g4-general-4G"

  # Public and Private
  networks = [
    "${data.triton_network.private.id}",
  ]

  provision        = "true"                    # note: we ARE provisioning as we are NOT using pre-built images.
  private_key_path = "${var.private_key_path}"

  prometheus_address = "${module.prometheus.prometheus_address}" # note: using address from the prometheus module

  bastion_host     = "${element(module.bastion.bastion_ip,0)}"
  bastion_user     = "${module.bastion.bastion_user}"
  bastion_role_tag = "${module.bastion.bastion_role_tag}"
}
