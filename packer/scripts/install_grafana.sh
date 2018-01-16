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

  log "Installing Grafana dependencies..."
  apt-get install -qq -y libfontconfig1
  apt-get install -f

  log "Downloading Grafana ${grafana_version}..."
  wget -q https://s3-us-west-2.amazonaws.com/grafana-releases/release/${path_file} -O ${path_file}
  dpkg -i ${path_file}

  log "Starting Grafana..."
  systemctl daemon-reload

  systemctl enable grafana-server.service
  systemctl start grafana-server.service

  # Give Grafana some time to start before further configuring. TODO: Make this more robust.
  sleep 5

  log "Creating Prometheus datasource in Grafana..."
  local -r prometheus_datasource="{\"name\":\"Prometheus\",\"type\":\"prometheus\",\"url\":\"http://${prometheus_address}:9090\",\"access\":\"proxy\",\"isDefault\":true}"
  curl 'http://localhost:3000/api/datasources' \
    -s \
    -X POST \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --basic --user admin:admin \
    --data-binary ${prometheus_datasource}
  echo '' # provide some buffer in the output after curl

  log "Creating Triton dashboard in Grafana..."
  curl 'http://localhost:3000/api/dashboards/db' \
    -s \
    -X POST \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --basic --user admin:admin \
    --data-binary "$(get_dashboard_json)"
  echo '' # provide some buffer in the output after curl

}

# get_dashboard_json - returns the triton dashboard json
#
# Parameters:
#   -
function get_dashboard_json() {
  echo '
{
  "overwrite": false,
  "dashboard": {
    "__requires": [
      {
        "type": "grafana",
        "id": "grafana",
        "name": "Grafana",
        "version": "4.4.3"
      },
      {
        "type": "panel",
        "id": "graph",
        "name": "Graph",
        "version": ""
      },
      {
        "type": "datasource",
        "id": "prometheus",
        "name": "Prometheus",
        "version": "1.0.0"
      }
    ],
    "annotations": {
      "list": []
    },
    "editable": true,
    "gnetId": null,
    "graphTooltip": 0,
    "hideControls": false,
    "id": null,
    "links": [],
    "refresh": "15s",
    "rows": [
      {
        "collapse": false,
        "panels": [
          {
            "aliasColors": {},
            "bars": false,
            "dashLength": 10,
            "dashes": false,
            "datasource": "Prometheus",
            "fill": 1,
            "id": 1,
            "legend": {
              "alignAsTable": true,
              "avg": false,
              "current": true,
              "max": false,
              "min": false,
              "rightSide": false,
              "show": true,
              "total": false,
              "values": true
            },
            "lines": true,
            "linewidth": 1,
            "links": [],
            "nullPointMode": "null",
            "percentage": false,
            "pointradius": 5,
            "points": false,
            "renderer": "flot",
            "seriesOverrides": [],
            "spaceLength": 10,
            "span": 12,
            "stack": false,
            "steppedLine": false,
            "targets": [
              {
                "expr": "sum( irate( net_agg_bytes_in{instance=~\"^$Instance$\"}[1m]) ) * 8",
                "format": "time_series",
                "interval": "",
                "intervalFactor": 2,
                "legendFormat": "Network In",
                "metric": "net_agg_bytes_in",
                "refId": "A",
                "step": 20
              },
              {
                "expr": "- sum( irate( net_agg_bytes_out{instance=~\"^$Instance$\"}[1m]) ) * 8",
                "format": "time_series",
                "hide": false,
                "interval": "",
                "intervalFactor": 2,
                "legendFormat": "Network Out",
                "metric": "net_agg_bytes_out",
                "refId": "B",
                "step": 20
              }
            ],
            "thresholds": [],
            "timeFrom": null,
            "timeShift": null,
            "title": "Aggregate Network I/O",
            "tooltip": {
              "shared": true,
              "sort": 0,
              "value_type": "individual"
            },
            "type": "graph",
            "xaxis": {
              "buckets": null,
              "mode": "time",
              "name": null,
              "show": true,
              "values": []
            },
            "yaxes": [
              {
                "format": "decbits",
                "label": "",
                "logBase": 1,
                "max": null,
                "min": null,
                "show": true
              },
              {
                "format": "short",
                "label": null,
                "logBase": 1,
                "max": null,
                "min": null,
                "show": true
              }
            ]
          }
        ],
        "repeat": null,
        "repeatIteration": null,
        "repeatRowId": null,
        "showTitle": false,
        "title": "Network",
        "titleSize": "h6"
      },
      {
        "collapse": false,
        "panels": [
          {
            "aliasColors": {},
            "bars": false,
            "dashLength": 10,
            "dashes": false,
            "datasource": "Prometheus",
            "decimals": null,
            "fill": 1,
            "id": 3,
            "legend": {
              "alignAsTable": true,
              "avg": false,
              "current": true,
              "hideEmpty": false,
              "hideZero": false,
              "max": false,
              "min": false,
              "rightSide": false,
              "show": true,
              "sideWidth": 800,
              "sort": "current",
              "sortDesc": true,
              "total": false,
              "values": true
            },
            "lines": true,
            "linewidth": 1,
            "links": [],
            "nullPointMode": "null as zero",
            "percentage": false,
            "pointradius": 5,
            "points": false,
            "renderer": "flot",
            "seriesOverrides": [],
            "spaceLength": 10,
            "span": 12,
            "stack": false,
            "steppedLine": false,
            "targets": [
              {
                "expr": "load_average{instance=~\"^$Instance$\"}",
                "format": "time_series",
                "interval": "",
                "intervalFactor": 2,
                "legendFormat": "{{ instance }}",
                "metric": "load_average",
                "refId": "A",
                "step": 20
              }
            ],
            "thresholds": [],
            "timeFrom": null,
            "timeShift": null,
            "title": "Load Average",
            "tooltip": {
              "shared": true,
              "sort": 0,
              "value_type": "individual"
            },
            "type": "graph",
            "xaxis": {
              "buckets": null,
              "mode": "time",
              "name": null,
              "show": true,
              "values": []
            },
            "yaxes": [
              {
                "format": "none",
                "label": "",
                "logBase": 1,
                "max": null,
                "min": "0",
                "show": true
              },
              {
                "format": "short",
                "label": null,
                "logBase": 1,
                "max": null,
                "min": null,
                "show": false
              }
            ]
          }
        ],
        "repeat": null,
        "repeatIteration": null,
        "repeatRowId": null,
        "showTitle": false,
        "title": "CPU",
        "titleSize": "h6"
      },
      {
        "collapse": false,
        "panels": [
          {
            "aliasColors": {},
            "bars": false,
            "dashLength": 10,
            "dashes": false,
            "datasource": "Prometheus",
            "decimals": null,
            "fill": 1,
            "id": 5,
            "legend": {
              "alignAsTable": true,
              "avg": false,
              "current": true,
              "hideEmpty": false,
              "hideZero": false,
              "max": false,
              "min": false,
              "rightSide": false,
              "show": true,
              "sideWidth": 800,
              "sort": "current",
              "sortDesc": true,
              "total": false,
              "values": true
            },
            "lines": true,
            "linewidth": 1,
            "links": [],
            "nullPointMode": "null as zero",
            "percentage": false,
            "pointradius": 5,
            "points": false,
            "renderer": "flot",
            "seriesOverrides": [],
            "spaceLength": 10,
            "span": 12,
            "stack": false,
            "steppedLine": false,
            "targets": [
              {
                "expr": "irate( cpu_wait_time{instance=~\"^$Instance$\"}[1m] )",
                "format": "time_series",
                "interval": "",
                "intervalFactor": 2,
                "legendFormat": "{{ instance }}",
                "metric": "cpu_wait_time",
                "refId": "A",
                "step": 20
              }
            ],
            "thresholds": [],
            "timeFrom": null,
            "timeShift": null,
            "title": "CPU Wait Time",
            "tooltip": {
              "shared": true,
              "sort": 0,
              "value_type": "individual"
            },
            "type": "graph",
            "xaxis": {
              "buckets": null,
              "mode": "time",
              "name": null,
              "show": true,
              "values": []
            },
            "yaxes": [
              {
                "format": "ns",
                "label": "",
                "logBase": 1,
                "max": null,
                "min": "0",
                "show": true
              },
              {
                "format": "short",
                "label": null,
                "logBase": 1,
                "max": null,
                "min": null,
                "show": false
              }
            ]
          }
        ],
        "repeat": null,
        "repeatIteration": null,
        "repeatRowId": null,
        "showTitle": false,
        "title": "CPU Wait Time",
        "titleSize": "h6"
      },
      {
        "collapse": false,
        "panels": [
          {
            "aliasColors": {},
            "bars": false,
            "dashLength": 10,
            "dashes": false,
            "datasource": "Prometheus",
            "fill": 1,
            "id": 4,
            "legend": {
              "alignAsTable": true,
              "avg": false,
              "current": true,
              "max": false,
              "min": false,
              "show": true,
              "sort": "current",
              "sortDesc": true,
              "total": false,
              "values": true
            },
            "lines": true,
            "linewidth": 1,
            "links": [],
            "nullPointMode": "null as zero",
            "percentage": false,
            "pointradius": 5,
            "points": false,
            "renderer": "flot",
            "seriesOverrides": [],
            "spaceLength": 10,
            "span": 12,
            "stack": false,
            "steppedLine": false,
            "targets": [
              {
                "expr": "mem_agg_usage{instance=~\"^$Instance$\"}",
                "format": "time_series",
                "interval": "",
                "intervalFactor": 2,
                "legendFormat": "{{ instance }}",
                "metric": "mem_agg_usage",
                "refId": "A",
                "step": 20
              }
            ],
            "thresholds": [],
            "timeFrom": null,
            "timeShift": null,
            "title": "Memory Usage",
            "tooltip": {
              "shared": true,
              "sort": 0,
              "value_type": "individual"
            },
            "type": "graph",
            "xaxis": {
              "buckets": null,
              "mode": "time",
              "name": null,
              "show": true,
              "values": []
            },
            "yaxes": [
              {
                "format": "decbytes",
                "label": null,
                "logBase": 1,
                "max": null,
                "min": "0",
                "show": true
              },
              {
                "format": "short",
                "label": null,
                "logBase": 1,
                "max": null,
                "min": null,
                "show": false
              }
            ]
          }
        ],
        "repeat": null,
        "repeatIteration": null,
        "repeatRowId": null,
        "showTitle": false,
        "title": "Memory",
        "titleSize": "h6"
      },
      {
        "collapse": false,
        "panels": [
          {
            "aliasColors": {},
            "bars": false,
            "dashLength": 10,
            "dashes": false,
            "datasource": "Prometheus",
            "decimals": null,
            "fill": 1,
            "id": 2,
            "legend": {
              "alignAsTable": true,
              "avg": false,
              "current": true,
              "hideEmpty": false,
              "hideZero": false,
              "max": false,
              "min": false,
              "rightSide": false,
              "show": true,
              "sideWidth": 800,
              "sort": "current",
              "sortDesc": true,
              "total": false,
              "values": true
            },
            "lines": true,
            "linewidth": 1,
            "links": [],
            "nullPointMode": "connected",
            "percentage": false,
            "pointradius": 5,
            "points": false,
            "renderer": "flot",
            "seriesOverrides": [],
            "spaceLength": 10,
            "span": 12,
            "stack": false,
            "steppedLine": false,
            "targets": [
              {
                "expr": "zfs_available{instance=~\"^$Instance$\"}",
                "format": "time_series",
                "interval": "",
                "intervalFactor": 2,
                "legendFormat": "{{ instance }}",
                "metric": "zfs_available",
                "refId": "B",
                "step": 20
              }
            ],
            "thresholds": [],
            "timeFrom": null,
            "timeShift": null,
            "title": "Disk Space Available",
            "tooltip": {
              "shared": true,
              "sort": 0,
              "value_type": "individual"
            },
            "type": "graph",
            "xaxis": {
              "buckets": null,
              "mode": "time",
              "name": null,
              "show": true,
              "values": []
            },
            "yaxes": [
              {
                "format": "decbytes",
                "label": "",
                "logBase": 1,
                "max": null,
                "min": "0",
                "show": true
              },
              {
                "format": "short",
                "label": null,
                "logBase": 1,
                "max": null,
                "min": null,
                "show": false
              }
            ]
          }
        ],
        "repeat": null,
        "repeatIteration": null,
        "repeatRowId": null,
        "showTitle": false,
        "title": "Disk",
        "titleSize": "h6"
      }
    ],
    "schemaVersion": 14,
    "style": "dark",
    "tags": [],
    "templating": {
      "list": [
        {
          "allValue": null,
          "current": {},
          "datasource": "Prometheus",
          "hide": 0,
          "includeAll": true,
          "label": null,
          "multi": false,
          "name": "Instance",
          "options": [],
          "query": "up",
          "refresh": 2,
          "regex": ".*instance=\\\"(.*?)\\\".*",
          "sort": 1,
          "tagValuesQuery": "",
          "tags": [],
          "tagsQuery": "",
          "type": "query",
          "useTags": false
        }
      ]
    },
    "time": {
      "from": "now-3h",
      "to": "now"
    },
    "timepicker": {
      "refresh_intervals": [
        "5s",
        "10s",
        "30s",
        "1m",
        "5m",
        "15m",
        "30m",
        "1h",
        "2h",
        "1d"
      ],
      "time_options": [
        "5m",
        "15m",
        "1h",
        "6h",
        "12h",
        "24h",
        "2d",
        "7d",
        "30d"
      ]
    },
    "timezone": "",
    "title": "Triton Cloud",
    "version": 24
  }
}' | tr -d '\n'

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
