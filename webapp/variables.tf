variable "env" { type = string }

variable "name" {
  type        = string
  description = "Name of the web app. Used verbatim as the resource name and must be globally unique."
}

variable "location" {
  type        = string
  description = "Azure region for the web app. Must match the region of the service plan."
}

variable "resource_group_name" { type = string }

variable "service_plan_id" {
  type        = string
  description = "Resource ID of the App Service Plan hosting this app. Pass appserviceplan.id."
}

variable "https_only" {
  type        = bool
  description = "Redirect all HTTP traffic to HTTPS."
  default     = true
}

variable "enabled" {
  type        = bool
  description = "Whether the app is running."
  default     = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Allow access from public networks. Leave false when fronting the app with a private endpoint."
  default     = false
}

variable "virtual_network_subnet_id" {
  type        = string
  description = "Subnet for regional VNet integration, used for the app's outbound traffic. Must be delegated to Microsoft.Web/serverFarms."
  default     = null
}

variable "app_settings" {
  type        = map(string)
  description = "Application settings exposed to the app as environment variables."
  default     = {}
  sensitive   = true
}

variable "connection_strings" {
  description = "Connection strings, keyed by name."
  type = map(object({
    type  = string
    value = string
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for connection_string in values(var.connection_strings) : contains([
        "APIHub", "Custom", "DocDb", "EventHub", "MySQL", "NotificationHub",
        "PostgreSQL", "RedisCache", "ServiceBus", "SQLAzure", "SQLServer",
      ], connection_string.type)
    ])
    error_message = "connection_strings type must be one of: APIHub, Custom, DocDb, EventHub, MySQL, NotificationHub, PostgreSQL, RedisCache, ServiceBus, SQLAzure, SQLServer."
  }
}

variable "site_config" {
  description = "Site configuration for the app. application_stack selects the runtime; set docker_image_name to run a container."
  type = object({
    always_on                         = optional(bool, true)
    app_command_line                  = optional(string)
    default_documents                 = optional(list(string))
    ftps_state                        = optional(string, "Disabled")
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

    application_stack = optional(object({
      docker_image_name        = optional(string)
      docker_registry_url      = optional(string)
      docker_registry_username = optional(string)
      docker_registry_password = optional(string)
      dotnet_version           = optional(string)
      go_version               = optional(string)
      java_server              = optional(string)
      java_server_version      = optional(string)
      java_version             = optional(string)
      node_version             = optional(string)
      php_version              = optional(string)
      python_version           = optional(string)
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
    condition     = contains(["Disabled", "FtpsOnly", "AllAllowed"], try(var.site_config.ftps_state, "Disabled"))
    error_message = "site_config.ftps_state must be one of: Disabled, FtpsOnly, AllAllowed."
  }

  validation {
    condition     = contains(["1.0", "1.1", "1.2", "1.3"], try(var.site_config.minimum_tls_version, "1.2"))
    error_message = "site_config.minimum_tls_version must be one of: 1.0, 1.1, 1.2, 1.3."
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
  description = "App setting and connection string names that stay with a slot rather than swapping with it."
  type = object({
    app_setting_names       = optional(list(string))
    connection_string_names = optional(list(string))
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
