#
# Variables
#
variable "private_key_path" {
  description = "The path to the private key to use for provisioning machines."
  type        = "string"
}

variable "prometheus_cmon_cert_file_path" {
  description = <<EOF
The path to the TLS certificate to use for authentication to the CMON endpoint.
The sdc-docker setup script is the easiest way to obtain this -
https://raw.githubusercontent.com/joyent/sdc-docker/master/tools/sdc-docker-setup.sh.
EOF

  type = "string"
}

variable "prometheus_cmon_key_file_path" {
  description = <<EOF
The path to the TLS key to use for authentication to the CMON endpoint.
The sdc-docker setup script is the easiest way to obtain this -
https://raw.githubusercontent.com/joyent/sdc-docker/master/tools/sdc-docker-setup.sh.
EOF

  type = "string"
}
