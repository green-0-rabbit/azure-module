resource "azurerm_linux_web_app" "this" {
  name                = local.resource_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = var.app_config.service_plan_id

  https_only                    = var.app_config.https_only
  enabled                       = var.app_config.enabled
  public_network_access_enabled = var.app_config.public_network_access_enabled
  virtual_network_subnet_id     = var.app_config.virtual_network_subnet_id
  vnet_image_pull_enabled       = var.app_config.vnet_image_pull_enabled

  # No FTP deployments, so the publishing credential path is closed off too.
  ftp_publish_basic_authentication_enabled = false

  app_settings = local.app_settings

  # https://learn.microsoft.com/en-us/entra/identity/managed-identities-azure-resources/manage-user-assigned-managed-identities-azure-portal
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.webapp_identity.id]
  }

  # Lets app_settings reference Key Vault secrets through the app's own identity.
  key_vault_reference_identity_id = azurerm_user_assigned_identity.webapp_identity.id

  dynamic "sticky_settings" {
    for_each = var.sticky_settings == null ? [] : [var.sticky_settings]
    content {
      app_setting_names = sticky_settings.value.app_setting_names
    }
  }

  site_config {
    # This module does not deploy over FTP, so the endpoint stays off rather than falling back
    # to the Azure default, which permits it.
    ftps_state = "Disabled"

    always_on                         = var.site_config.always_on
    app_command_line                  = var.site_config.app_command_line
    default_documents                 = var.site_config.default_documents
    health_check_path                 = var.site_config.health_check_path
    health_check_eviction_time_in_min = local.health_check_eviction_time_in_min
    http2_enabled                     = var.site_config.http2_enabled
    load_balancing_mode               = var.site_config.load_balancing_mode
    minimum_tls_version               = var.site_config.minimum_tls_version
    use_32_bit_worker                 = var.site_config.use_32_bit_worker
    websockets_enabled                = var.site_config.websockets_enabled
    worker_count                      = var.site_config.worker_count
    ip_restriction_default_action     = var.site_config.ip_restriction_default_action

    # Route outbound traffic through the integration subnet whenever one is configured.
    vnet_route_all_enabled = coalesce(var.site_config.vnet_route_all_enabled, var.app_config.virtual_network_subnet_id != null)

    container_registry_use_managed_identity       = local.use_acr_managed_identity
    container_registry_managed_identity_client_id = local.use_acr_managed_identity ? azurerm_user_assigned_identity.webapp_identity.client_id : null

    dynamic "application_stack" {
      for_each = var.site_config.application_stack == null ? [] : [var.site_config.application_stack]
      content {
        docker_image_name        = application_stack.value.docker_image_name
        docker_registry_url      = local.docker_registry_url
        docker_registry_username = application_stack.value.docker_registry_username
        docker_registry_password = application_stack.value.docker_registry_password
      }
    }

    dynamic "cors" {
      for_each = var.site_config.cors == null ? [] : [var.site_config.cors]
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }

    dynamic "ip_restriction" {
      for_each = var.site_config.ip_restrictions
      content {
        name                      = ip_restriction.value.name
        action                    = ip_restriction.value.action
        priority                  = ip_restriction.value.priority
        description               = ip_restriction.value.description
        ip_address                = ip_restriction.value.ip_address
        service_tag               = ip_restriction.value.service_tag
        virtual_network_subnet_id = ip_restriction.value.virtual_network_subnet_id
      }
    }
  }

  tags = local.tags

  depends_on = [
    azurerm_role_assignment.acr_pull_uai
  ]
}
