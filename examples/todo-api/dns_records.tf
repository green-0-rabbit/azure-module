resource "azurerm_private_dns_a_record" "aca_apex" {
  name                = "@"
  zone_name           = azurerm_private_dns_zone.dev_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [module.container_app_environment.private_endpoint_ip]
}

resource "azurerm_private_dns_a_record" "aca_wildcard" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.dev_zone.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 300
  records             = [module.container_app_environment.private_endpoint_ip]
}
