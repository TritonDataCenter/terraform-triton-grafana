#
# Outputs
#
output "grafana_ip" {
  value = ["${triton_machine.grafana.*.primaryip}"]
}

output "grafana_role_tag" {
  value = "${var.role_tag}"
}

output "grafana_cns_service_name" {
  value = "${var.cns_service_name}"
}

output "grafana_address" {
  value = "${local.grafana_address}"
}
