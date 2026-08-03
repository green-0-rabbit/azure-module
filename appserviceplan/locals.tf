locals {
  resource_name = "${lower(var.name)}-${var.env}"

  tags = merge({ "ResourceName" = local.resource_name }, var.tags)

  # Isolated v2 SKUs are the only ones an App Service Environment v3 accepts, and they are not
  # usable outside one. The pairing is enforced by a precondition on the plan.
  is_isolated_v2       = can(regex("^I[1-6]v2$", var.sku_name))
  uses_app_service_env = var.app_service_environment_id != null
  isolated_matches_ase = local.is_isolated_v2 == local.uses_app_service_env
}
