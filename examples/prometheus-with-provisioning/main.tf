#
# Remote State
#
terraform {
  backend "manta" {
    path       = "terraform-state/grafana/"
    objectName = "terraform.tfstate"
  }
}

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
  source = "github.com/joyent/terraform-triton-prometheus"

  name    = "prometheus-with-provisioning"
  image   = "${data.triton_image.ubuntu.id}" # note: using the UBUNTU image here
  package = "g4-general-4G"

  # Private
  networks = [
    "${data.triton_network.private.id}",
  ]

  provision        = "true"                    # note: we ARE provisioning as we are NOT using pre-built images.
  private_key_path = "${var.private_key_path}"

  client_access = ["any"]

  cmon_cert_file_path = "${var.prometheus_cmon_cert_file_path}"
  cmon_key_file_path  = "${var.prometheus_cmon_key_file_path}"

  bastion_address          = "${module.bastion.bastion_address}"
  bastion_user             = "${module.bastion.bastion_user}"
  bastion_cns_service_name = "${module.bastion.bastion_cns_service_name}"
}

module "grafana" {
  source = "../../"

  name    = "prometheus-with-provisioning"
  image   = "${data.triton_image.ubuntu.id}" # note: using the UBUNTU image here
  package = "g4-general-4G"

  # Public and Private
  networks = [
    "${data.triton_network.public.id}",
    "${data.triton_network.private.id}",
  ]

  provision        = "true"                    # note: we ARE provisioning as we are NOT using pre-built images.
  private_key_path = "${var.private_key_path}"

  client_access = ["any"]

  prometheus_address = "${module.prometheus.prometheus_address}" # note: using address from the prometheus module

  bastion_address          = "${module.bastion.bastion_address}"
  bastion_user             = "${module.bastion.bastion_user}"
  bastion_cns_service_name = "${module.bastion.bastion_cns_service_name}"
}
