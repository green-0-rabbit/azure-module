locals {
  ase_name = "ase-${var.project}-${var.env}"

  # Azure derives the environment's DNS suffix from its name, so this is known at plan time even
  # though module.app_service_environment.dns_suffix is not. That lets the zone go through the
  # vnet module, whose for_each needs plan-time keys. The check block below proves the two agree.
  ase_dns_suffix = "${local.ase_name}.${var.ase_domain_suffix}"
}

module "app_service_environment" {
  source = "../../appserviceenv"

  name                = local.ase_name
  env                 = var.env
  resource_group_name = azurerm_resource_group.rg.name

  # The environment takes its region from this subnet, which must be delegated to
  # Microsoft.Web/hostingEnvironments and hold nothing else.
  subnet_id = module.vnet_spoke.subnet_ids["AseSubnet"]

  # Internal load balancer: the environment and every app in it stay inside the VNet.
  internal_load_balancing_mode = "Web, Publishing"

  tags = var.tags
}
