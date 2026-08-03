locals {
  resource_name = "${lower(var.name)}-${var.env}"

  tags = merge({ "ResourceName" = local.resource_name }, var.tags)

  # An ILB environment is only reachable from inside the VNet, so it needs a private DNS zone
  # named after the environment's dns_suffix. That zone is the caller's responsibility.
  is_internal = var.internal_load_balancing_mode != "None"
}
