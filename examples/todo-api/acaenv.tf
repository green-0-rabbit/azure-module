module "container_app_environment" {
  source = "../../acaenv"

  name                               = "${var.project}-acaenv-${var.env}"
  env                                = var.env
  location                           = var.location
  resource_group_name                = azurerm_resource_group.rg.name
  infrastructure_subnet_id           = module.vnet_spoke.subnet_ids["ACASubnet"]
  infrastructure_resource_group_name = "aca-private-${var.env}-rg"

  workload_profile = {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }

  # Private endpoint
  networking = {
    subnet_id                    = module.vnet_spoke.subnet_ids["PrivateEndpointSubnet"]
    static_ip_address_allocation = true
    pe_ip                        = var.aca_private_endpoint_ip
  }

  dns = {
    register_pe_to_dns = true
    dns_id             = azurerm_private_dns_zone.aca.id
  }

  tags = var.tags
}
