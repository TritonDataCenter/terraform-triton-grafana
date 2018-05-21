#
# Terraform/Providers
#
terraform {
  required_version = ">= 0.11.0"
}

provider "triton" {
  version = ">= 0.4.1"
}

#
# Data sources
#
data "triton_datacenter" "current" {}

data "triton_account" "current" {}

#
# Locals
#
locals {
  grafana_address = "${var.cns_service_name}.svc.${data.triton_account.current.id}.${data.triton_datacenter.current.name}.${var.cns_fqdn_base}"
}

#
# Machines
#
resource "triton_machine" "grafana" {
  name    = "${var.name}-grafana"
  package = "${var.package}"
  image   = "${var.image}"

  firewall_enabled = true

  networks = ["${var.networks}"]

  cns {
    services = ["${var.cns_service_name}"]
  }

  metadata {
    grafana_version    = "${var.version}"
    prometheus_address = "${var.prometheus_address}"
  }
}

#
# Firewall Rules
#
resource "triton_firewall_rule" "ssh" {
  rule        = "FROM tag \"triton.cns.services\" = \"${var.bastion_cns_service_name}\" TO tag \"triton.cns.services\" = \"${var.cns_service_name}\" ALLOW tcp PORT 22"
  enabled     = true
  description = "${var.name} - Allow access from bastion hosts to Grafana servers."
}

resource "triton_firewall_rule" "web_access" {
  count = "${length(var.client_access)}"

  rule        = "FROM ${var.client_access[count.index]} TO tag \"triton.cns.services\" = \"${var.cns_service_name}\" ALLOW tcp PORT 3000"
  enabled     = true
  description = "${var.name} - Allow access from clients to Grafana servers."
}
