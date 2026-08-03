terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # certificate_key_vault on azurerm_container_app_environment_certificate is absent in 4.50.0.
      version = ">= 4.68.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.7.0"
    }
  }

  required_version = ">= 1.1.0"
}