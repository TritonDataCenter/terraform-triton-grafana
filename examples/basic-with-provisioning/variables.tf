#
# Variables
#
variable "private_key_path" {
  description = "The path to the private key to use for provisioning machines."
  type        = "string"
}

variable "prometheus_address" {
  description = "The address to the Prometheus server - e.g. prometheus.your-company.com."
  type        = "string"
}
