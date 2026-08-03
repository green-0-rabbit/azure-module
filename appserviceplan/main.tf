resource "azurerm_service_plan" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name

  app_service_environment_id   = var.app_service_environment_id
  worker_count                 = var.worker_count
  per_site_scaling_enabled     = var.per_site_scaling_enabled
  zone_balancing_enabled       = var.zone_balancing_enabled
  maximum_elastic_worker_count = var.maximum_elastic_worker_count

  tags = local.tags

  lifecycle {
    precondition {
      condition     = local.isolated_matches_ase
      error_message = "Isolated v2 SKUs require app_service_environment_id, and app_service_environment_id requires an Isolated v2 sku_name."
    }
  }
}
