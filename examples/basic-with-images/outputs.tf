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
