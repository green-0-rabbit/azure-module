resource "azurerm_app_service_environment_v3" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  internal_load_balancing_mode           = var.internal_load_balancing_mode
  zone_redundant                         = var.zone_redundant
  dedicated_host_count                   = var.dedicated_host_count
  allow_new_private_endpoint_connections = var.allow_new_private_endpoint_connections
  remote_debugging_enabled               = var.remote_debugging_enabled

  dynamic "cluster_setting" {
    for_each = var.cluster_settings
    content {
      name  = cluster_setting.key
      value = cluster_setting.value
    }
  }

  tags = local.tags
}

# Environment platform logs only. Application traffic is captured per site, by the diagnostic
# setting on the webapp module.
resource "azurerm_monitor_diagnostic_setting" "ase_to_law" {
  count = var.diagnostic_setting != null ? 1 : 0

  name                       = "diag-${local.resource_name}-law"
  target_resource_id         = azurerm_app_service_environment_v3.this.id
  log_analytics_workspace_id = var.diagnostic_setting.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(var.diagnostic_setting.log_categories)
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = var.diagnostic_setting.enable_all_metrics ? toset(["AllMetrics"]) : toset([])
    content {
      category = enabled_metric.value
    }
  }
}
