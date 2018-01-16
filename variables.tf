#
# Variables
#
variable "name" {
  description = "The name of the environment."
  type        = "string"
}

variable "image" {
  description = "The image to deploy as the Grafana machine(s)."
  type        = "string"
}

variable "package" {
  description = "The package to deploy as the Grafana machine(s)."
  type        = "string"
}

variable "networks" {
  description = "The networks to deploy the Grafana machine(s) within."
  type        = "list"
}

variable "private_key_path" {
  description = "The path to the private key to use for provisioning machines."
  type        = "string"
}

variable "user" {
  description = "The user to use for provisioning machines."
  type        = "string"
  default     = "root"
}

variable "role_tag" {
  description = "The 'role' tag for the Grafana machine(s)."
  type        = "string"
  default     = "grafana"
}

variable "provision" {
  description = "Boolean 'switch' to indicate if Terraform should do the machine provisioning to install and configure Grafana."
  type        = "string"
}

variable "version" {
  description = "The version of Grafana to install. See https://grafana.com/grafana/download."
  default     = "4.6.3"
  type        = "string"
}

variable "cns_service_name" {
  description = "The Grafana CNS service name. Note: this is the service name only, not the full CNS record."
  type        = "string"
  default     = "grafana"
}

variable "prometheus_address" {
  description = <<EOF
The address to the Prometheus server - e.g. prometheus.your-company.com.
Note: This will be ignored if pre-built Grafana images are being used.
EOF

  type = "string"
}

variable "cns_fqdn_base" {
  description = "The fully qualified domain name base for the CNS address - e.g. 'triton.zone' for Joyent Public Cloud."
  type        = "string"
  default     = "cns.joyent.com"
}

variable "client_access" {
  description = <<EOF
'From' targets to allow client access to Grafana' web port - i.e. access from other VMs or public internet.
See https://docs.joyent.com/public-cloud/network/firewall/cloud-firewall-rules-reference#target
for target syntax.
EOF

  type    = "list"
  default = ["all vms"]
}

variable "bastion_host" {
  description = "The Bastion host to use for provisioning."
  type        = "string"
}

variable "bastion_user" {
  description = "The Bastion user to use for provisioning."
  type        = "string"
}

variable "bastion_role_tag" {
  description = "The 'role' tag for the Grafana machine(s) to allow access FROM the Bastion machine(s)."
  type        = "string"
}
