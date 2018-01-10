#!/bin/bash
#
# Installs and configures Grafana.
#
# Note: Generally follows guidelines at https://web.archive.org/web/20170701145736/https://google.github.io/styleguide/shell.xml.
#

set -e

# check_prerequisites - exits if distro is not supported.
#
# Parameters:
#     None.
function check_prerequisites() {
  local distro
  if [[ -f "/etc/lsb-release" ]]; then
    distro="Ubuntu"
  fi

  if [[ -z "${distro}" ]]; then
    log "Unsupported platform. Exiting..."
    exit 1
  fi
}

# install_dependencies - installs dependencies
#
# Parameters:
#     $1: the name of the distribution.
function install_dependencies() {
  log "Updating package index..."
  apt-get -qq -y update
  log "Installing prerequisites..."
  apt-get -qq -y install wget
}

# check_arguments - returns 0 if prerequisites are satisfied or 1 if not.
#
# Parameters:
#     $1: the grafana version
#     $2: the prometheus address
function check_arguments() {
  local -r grafana_version=${1}
  local -r prometheus_address=${2}

  if [[ -z "${grafana_version}" ]]; then
    log "Grafana Version not provided. Exiting..."
    exit 1
  fi

  if [[ -z "${prometheus_address}" ]]; then
    log "Prometheus Address not provided. Exiting..."
    exit 1
  fi
}

# install_grafana - installs grafana
#
# Parameters:
#     $1: the grafana version
#     $2: the prometheus address
function install_grafana() {
  local -r grafana_version=${1}
  local -r prometheus_address=${2}

  local -r path_file="grafana_${grafana_version}_amd64.deb"

  log "Installing grafana prerequisites..."
  apt-get install -qq -y libfontconfig1
  apt-get install -f

  log "Downloading grafana ${grafana_version}..."
  wget -q https://s3-us-west-2.amazonaws.com/grafana-releases/release/${path_file} -O ${path_file}
  dpkg -i ${path_file}

  # TODO(clstokes): More standard way to check for running service?
  log "Starting grafana..."
  systemctl daemon-reload

  systemctl enable grafana-server.service
  systemctl start grafana-server.service

  # Give Grafana some time to start before further configuring. TODO: Make this more robust.
  sleep 5

  if [[ ${?} -ne 0 ]]; then
    log "Grafana not running. Unable to configure. Exiting..."
    exit 1
  fi

  local -r prometheus_datasource="{\"name\":\"Prometheus\",\"type\":\"prometheus\",\"url\":\"http://${prometheus_address}:9090\",\"access\":\"proxy\",\"isDefault\":true}"

  # Create Prometheus datasource in Grafana
  curl 'http://localhost:3000/api/datasources' \
    -s \
    -X POST \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --basic --user admin:admin \
    --data-binary ${prometheus_datasource}

    # TODO(clstokes): Import dashboard too.

    # buffer the previous line in the overall script output
    echo ''
}

# info - prints an informational message
#
# Parameters:
#     $1: the message
function log() {
  local -r message=${1}
  local -r script_name=$(basename ${0})
  echo -e "==> ${script_name}: ${message}"
}

# main
function main() {
  check_prerequisites

  local -r arg_grafana_version=$(mdata-get 'grafana_version')
  local -r arg_prometheus_address=$(mdata-get 'prometheus_address')

  check_arguments \
    ${arg_grafana_version} ${arg_prometheus_address}

  install_dependencies

  install_grafana \
    ${arg_grafana_version} ${arg_prometheus_address}

  log "Done."
}

main
