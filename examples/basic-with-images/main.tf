#
# Data Sources
#
data "triton_image" "ubuntu" {
  name        = "ubuntu-16.04"
  type        = "lx-dataset"
  most_recent = true
}

data "triton_image" "grafana" {
  name        = "grafana"
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

  name    = "prometheus-with-images"
  image   = "${data.triton_image.ubuntu.id}" # note: using the UBUNTU image here
  package = "g4-general-4G"

  # Public and Private
  networks = [
    "${data.triton_network.public.id}",
    "${data.triton_network.private.id}",
  ]
}

module "grafana" {
  source = "../../"

  name    = "grafana-basic-with-provisioning"
  image   = "${data.triton_image.grafana.id}" # note: using the GRAFANA image here
  package = "g4-general-4G"

  # Public and Private
  networks = [
    "${data.triton_network.private.id}",
  ]

  provision        = "false"                   # note: we are NOT provisioning as we are using PRE-built images.
  private_key_path = "${var.private_key_path}"

  prometheus_address = "" # note: unused since we're using pre-built images.

  bastion_host     = "${element(module.bastion.bastion_ip,0)}"
  bastion_user     = "${module.bastion.bastion_user}"
  bastion_role_tag = "${module.bastion.bastion_role_tag}"
}
