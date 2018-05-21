#
# Outputs
#
output "grafana_primaryip" {
  value = ["${triton_machine.grafana.*.primaryip}"]
}

output "grafana_cns_service_name" {
  value = "${var.cns_service_name}"
}

output "grafana_address" {
  value = "${local.grafana_address}"
}
