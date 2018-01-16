#
# Outputs
#
output "bastion_ip" {
  value = ["${module.bastion.bastion_ip}"]
}

output "grafana_ip" {
  value = ["${module.grafana.grafana_ip}"]
}

output "grafana_address" {
  value = ["${module.grafana.grafana_address}"]
}

output "prometheus_ip" {
  value = ["${module.prometheus.prometheus_ip}"]
}

output "prometheus_address" {
  value = ["${module.prometheus.prometheus_address}"]
}
