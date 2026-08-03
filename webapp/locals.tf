locals {
  resource_name = "${lower(var.app_config.name)}-${var.env}"

  tags = merge({ "ResourceName" = local.resource_name }, var.tags)

  pep_subresource_name    = "sites"
  pep_member_name         = "sites"
  pep_ip_config_name      = "webapp-pe-ip-config"
  pep_prefix              = "webapp"
  enable_private_endpoint = var.networking != null && var.dns != null

  networking = var.networking != null ? var.networking : {
    subnet_id                    = ""
    static_ip_address_allocation = false
    pe_ip                        = null
  }

  dns = var.dns != null ? var.dns : {
    register_pe_to_dns = false
    dns_id             = null
  }

  # Pulling images from ACR with the app's identity needs both the flag and the client id, so
  # derive them together rather than making the caller keep the two in sync.
  use_acr_managed_identity = var.acr_config != null && try(var.acr_config.use_managed_identity, true)

  create_acr_role_assignment = local.use_acr_managed_identity && try(var.acr_config.create_role_assignment, true)

  # Vault name from the resource id in kv_config, used to check that every secret id belongs to
  # that vault rather than some other one.
  kv_vault_name = var.kv_config != null ? reverse(split("/", var.kv_config.kv_id))[0] : null

  # App Service resolves a setting shaped like @Microsoft.KeyVault(SecretUri=...) against Key Vault
  # at runtime, using key_vault_reference_identity_id. Build the reference here so callers pass a
  # plain secret URI rather than hand-writing the wrapper.
  key_vault_app_settings = {
    for setting_name, secret_uri in var.key_vault_secrets :
    setting_name => "@Microsoft.KeyVault(SecretUri=${secret_uri})"
  }

  app_settings = merge(var.app_settings, local.key_vault_app_settings)

  # azurerm requires health_check_path and health_check_eviction_time_in_min together, so supply
  # the eviction time whenever a path is set, and suppress it when there is no path to check.
  health_check_eviction_time_in_min = (
    var.site_config.health_check_path == null
    ? null
    : (var.site_config.health_check_eviction_time_in_min != null ? var.site_config.health_check_eviction_time_in_min : 2)
  )

  # Default the registry to the one in acr_config so the same registry is not named twice. An
  # explicit docker_registry_url still wins, for images pulled from elsewhere.
  docker_registry_url = (
    try(var.site_config.application_stack.docker_registry_url, null) != null
    ? var.site_config.application_stack.docker_registry_url
    : (var.acr_config != null ? "https://${var.acr_config.registry_fqdn}" : null)
  )
}
