module "app_service_plan" {
  source = "../../appserviceplan"

  name                = "asp-${var.project}-${var.env}"
  env                 = var.env
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  os_type = "Linux"

  # Isolated v2 is the only tier an App Service Environment accepts, and it is only valid inside
  # one. The module has a precondition that keeps these two inputs in step.
  sku_name                   = "I1v2"
  app_service_environment_id = module.app_service_environment.id

  worker_count = 1

  tags = var.tags
}
