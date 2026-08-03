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

  # Internal load balancer: the environment and every app in it stay inside the VNet. This is how
  # an environment is made private; a private endpoint cannot target one. Azure rejects it with
  # "Private Link for ASE is invalid. If this is an ASEv3, private endpoints can still be added to
  # individual apps within the ASEv3." That is the structural difference from acaenv, which does
  # take a private endpoint on the environment itself.
  #
  # Consequences, if this grows past one app: App Service has no environment-level router, so
  # there is no equivalent of acaenv's http_route_configs for path matching, rewrites or weighted
  # targets across apps. And each app would need its own private endpoint. A private Application
  # Gateway or API Management in front of the environment solves both: it supplies the routing
  # rules, and collapses ingress to a single private entry point for every app behind it.
  internal_load_balancing_mode = "Web, Publishing"

  tags = var.tags
}
