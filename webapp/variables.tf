variable "app_config" {
  description = <<-EOT
    Core configuration for the web app. The resource is named "<name>-<env>", which must be
    globally unique across Azure. virtual_network_subnet_id enables regional VNet integration for
    outbound traffic and must be delegated to Microsoft.Web/serverFarms.
  EOT
  type = object({
    name                          = string
    service_plan_id               = string
    https_only                    = optional(bool, true)
    enabled                       = optional(bool, true)
    public_network_access_enabled = optional(bool, false)
    virtual_network_subnet_id     = optional(string)

    # Pull container images over the virtual network. Must be true when the plan sits inside an
    # App Service Environment, which rejects it being disabled, and when the registry is only
    # reachable privately. The provider sends false when this is unset.
    vnet_image_pull_enabled = optional(bool, false)
  })
}

variable "env" { type = string }

variable "location" {
  type        = string
  description = "Azure region for the web app. Must match the region of the service plan."
}

variable "resource_group_name" { type = string }

variable "app_settings" {
  type        = map(string)
  description = "Application settings exposed to the app as environment variables."
  default     = {}
  sensitive   = true
}

variable "key_vault_secrets" {
  description = <<-EOT
    App settings whose values are fetched from Key Vault at runtime, keyed by app setting name
    with the Key Vault secret id as the value. Secrets are always read from the vault in kv_config,
    which is required when this is set and is checked against each id.

    The module wraps each id in @Microsoft.KeyVault(SecretUri=...), which App Service resolves
    through the identity in key_vault_reference_identity_id -- the identity this module creates.
    kv_config also grants that identity "Key Vault Secrets User" on the vault.

    Leave the version off the id (.../secrets/name rather than .../secrets/name/version) so
    rotations are picked up. App Service caches resolved references, so a rotation takes effect
    within 24 hours, or immediately on the next app configuration change.

    A key here overrides the same key in app_settings.
  EOT
  type        = map(string)
  default     = {}

  validation {
    condition = alltrue([
      for secret_id in values(var.key_vault_secrets) : can(regex("^https://[^/]+/secrets/[^/]+", secret_id))
    ])
    error_message = "Each key_vault_secrets value must be a Key Vault secret id, for example https://my-vault.vault.azure.net/secrets/my-secret."
  }
}

variable "site_config" {
  description = "Site configuration for the app. application_stack.docker_image_name names the container image to run."
  type = object({
    always_on                         = optional(bool, true)
    app_command_line                  = optional(string)
    default_documents                 = optional(list(string))
    health_check_path                 = optional(string)
    health_check_eviction_time_in_min = optional(number)
    http2_enabled                     = optional(bool, true)
    load_balancing_mode               = optional(string)
    minimum_tls_version               = optional(string, "1.2")
    use_32_bit_worker                 = optional(bool, false)
    vnet_route_all_enabled            = optional(bool)
    websockets_enabled                = optional(bool, false)
    worker_count                      = optional(number)
    ip_restriction_default_action     = optional(string, "Allow")

    # This module deploys containers only. docker_registry_url defaults to the registry in
    # acr_config, so it only needs setting when pulling from somewhere other than that registry.
    application_stack = optional(object({
      docker_image_name        = string
      docker_registry_url      = optional(string)
      docker_registry_username = optional(string)
      docker_registry_password = optional(string)
    }))

    cors = optional(object({
      allowed_origins     = list(string)
      support_credentials = optional(bool, false)
    }))

    ip_restrictions = optional(list(object({
      name                      = optional(string)
      action                    = optional(string, "Allow")
      priority                  = optional(number)
      description               = optional(string)
      ip_address                = optional(string)
      service_tag               = optional(string)
      virtual_network_subnet_id = optional(string)
    })), [])
  })
  default = {}

  validation {
    condition     = contains(["1.0", "1.1", "1.2", "1.3"], try(var.site_config.minimum_tls_version, "1.2"))
    error_message = "site_config.minimum_tls_version must be one of: 1.0, 1.1, 1.2, 1.3."
  }

  validation {
    condition = (
      try(var.site_config.health_check_eviction_time_in_min, null) == null
      || (var.site_config.health_check_eviction_time_in_min >= 2 && var.site_config.health_check_eviction_time_in_min <= 10)
    )
    error_message = "site_config.health_check_eviction_time_in_min must be between 2 and 10."
  }

  validation {
    condition = alltrue([
      for ip_restriction in try(var.site_config.ip_restrictions, []) : length(compact([
        try(ip_restriction.ip_address, null),
        try(ip_restriction.service_tag, null),
        try(ip_restriction.virtual_network_subnet_id, null),
      ])) == 1
    ])
    error_message = "Each site_config.ip_restrictions entry must set exactly one of ip_address, service_tag, or virtual_network_subnet_id."
  }
}

variable "sticky_settings" {
  description = "App setting names that stay with a slot rather than swapping with it."
  type = object({
    app_setting_names = optional(list(string))
  })
  default = null
}

variable "acr_config" {
  description = "Configuration for the Azure Container Registry the app pulls images from, including whether to create the AcrPull role assignment."
  type = object({
    registry_fqdn          = string
    acr_id                 = optional(string)
    create_role_assignment = optional(bool, true)
    use_managed_identity   = optional(bool, true)
  })
  default = null

  validation {
    condition = var.acr_config == null || (
      !(try(var.acr_config.use_managed_identity, true) && try(var.acr_config.create_role_assignment, true))
      || try(var.acr_config.acr_id, null) != null
    )
    error_message = "acr_config.acr_id is required when use_managed_identity and create_role_assignment are both true, since the module creates the AcrPull assignment against it."
  }
}

variable "kv_config" {
  description = "Configuration for Key Vault integration, including Key Vault Resource ID and whether to create the Key Vault Secrets User role assignment."
  type = object({
    kv_id                  = string
    create_role_assignment = optional(bool, true)
  })
  default = null
}

variable "networking" {
  description = "Private endpoint networking configuration"
  type = object({
    subnet_id                    = string
    static_ip_address_allocation = optional(bool, false)
    pe_ip                        = optional(string)
  })
  default  = null
  nullable = true

  validation {
    condition = var.networking == null || (
      (
        var.networking.static_ip_address_allocation
        && can(cidrnetmask("${var.networking.pe_ip}/32"))
      ) || !var.networking.static_ip_address_allocation
    )
    error_message = "When static IP allocation is enabled, networking.pe_ip must be a valid IPv4 address"
  }
}

variable "dns" {
  description = "Private endpoint DNS registration configuration"
  type = object({
    register_pe_to_dns = optional(bool, false)
    dns_id             = optional(string)
  })
  default  = null
  nullable = true

  validation {
    condition = var.dns == null || (
      (
        var.dns.register_pe_to_dns
        && var.dns.dns_id != null
      ) || !var.dns.register_pe_to_dns
    )
    error_message = "When DNS registration is enabled, dns.dns_id must be provided"
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
