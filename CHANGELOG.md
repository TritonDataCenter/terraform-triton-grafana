
## 1.0.0-rc2 (2018-05-21)

BACKWARDS INCOMPATIBILITIES / NOTES:

  * Update Grafana to 5.1.3.
  * Changes for [terraform-triton-bastion - 1.0.0-rc2](https://github.com/joyent/terraform-triton-bastion/blob/master/CHANGELOG.md#100-rc2-unreleased).
  * Change `grafana_ip` output to `grafana_primaryip`. 
  * Remove `role_tag_value` variable and `grafana_role_tag` output.

IMPROVEMENTS:

  * Add `cns_fqdn_base` variable to allow customization of CNS names.
  * Change firewall rules to rely on CNS service names instead of (now removed) `role` tag.
  
## 1.0.0-rc1 (2018-02-10)

  * Initial working example
