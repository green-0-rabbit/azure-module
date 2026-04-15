variable "env" { type = string }

variable "name" {
  type        = string
  description = "Name of the Container App Environment"
}

variable "location" {
  type        = string
  description = "Azure region for the environment (must be Switzerland North/West)."
  validation {
    condition     = contains(["switzerlandnorth", "switzerlandwest", "eastus", "westeurope", "northeurope"], var.location)
    error_message = "location must be one of: switzerlandnorth, switzerlandwest, eastus, westeurope, northeurope."
  }
}

variable "resource_group_name" { type = string }
variable "infrastructure_subnet_id" {
  type    = string
  default = null
}
variable "infrastructure_resource_group_name" {
  type    = string
  default = null
}
variable "log_analytics_workspace_id" {
  type    = string
  default = null
}
variable "lb_internal_only" {
  type    = bool
  default = true
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Public network access for the Container Apps environment."
  default     = false
}

variable "workload_profile" {
  type = object({
    name                  = string
    workload_profile_type = string
    minimum_count         = optional(number)
    maximum_count         = optional(number)
  })
  validation {
    condition     = contains(["Consumption", "D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32"], var.workload_profile.workload_profile_type)
    error_message = "workload_profile.workload_profile_type must be one of: Consumption, D4, D8, D16, D32, E4, E8, E16, E32."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "certificate_config" {
  description = "Configuration for the Container App Environment Certificate"
  type = object({
    name                    = string
    certificate_blob_base64 = string
    certificate_password    = optional(string, "")
  })
  default = null
}

variable "http_route_configs" {
  description = "Optional environment-level HTTP route configurations keyed by Azure child resource name. Route config names must be 3-63 chars and match ^[a-z][a-z0-9]*$."
  type = map(object({
    custom_domains = optional(list(object({
      name           = string
      binding_type   = optional(string)
      certificate_id = optional(string)
    })), [])
    rules = list(object({
      description = optional(string)
      routes = list(object({
        match = object({
          path                  = optional(string)
          prefix                = optional(string)
          path_separated_prefix = optional(string)
          case_sensitive        = optional(bool)
        })
        action = optional(object({
          prefix_rewrite = optional(string)
        }))
      }))
      targets = list(object({
        container_app = string
        label         = optional(string)
        revision      = optional(string)
        weight        = optional(number)
      }))
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for route_config_name in keys(var.http_route_configs) :
      length(route_config_name) >= 3
      && length(route_config_name) <= 63
      && can(regex("^[a-z][a-z0-9]*$", route_config_name))
    ])
    error_message = "http_route_configs keys must be 3-63 characters, start with a lowercase letter, and contain only lowercase letters and numbers."
  }

  validation {
    condition = alltrue([
      for route_config in values(var.http_route_configs) : length(route_config.rules) > 0
    ])
    error_message = "Each http_route_configs entry must contain at least one rule."
  }

  validation {
    condition = alltrue(flatten([
      for route_config in values(var.http_route_configs) : [
        for rule in route_config.rules : length(rule.routes) > 0 && length(rule.targets) > 0
      ]
    ]))
    error_message = "Each HTTP route rule must contain at least one route and at least one target."
  }

  validation {
    condition = alltrue(flatten([
      for route_config in values(var.http_route_configs) : [
        for rule in route_config.rules : [
          for route in rule.routes : length(compact([
            try(route.match.path, null),
            try(route.match.prefix, null),
            try(route.match.path_separated_prefix, null),
          ])) > 0
        ]
      ]
    ]))
    error_message = "Each HTTP route match must set at least one of match.path, match.prefix, or match.path_separated_prefix."
  }

  validation {
    condition = alltrue(flatten([
      for route_config in values(var.http_route_configs) : [
        for custom_domain in route_config.custom_domains : (
          contains([
            "Auto",
            "Disabled",
            "SniEnabled",
            ], coalesce(
            try(custom_domain.binding_type, null),
            try(custom_domain.certificate_id, null) != null ? "SniEnabled" : "Disabled"
          ))
          && (
            coalesce(
              try(custom_domain.binding_type, null),
              try(custom_domain.certificate_id, null) != null ? "SniEnabled" : "Disabled"
            ) != "SniEnabled"
            || try(custom_domain.certificate_id, null) != null
            || var.certificate_config != null
          )
        )
      ]
    ]))
    error_message = "HTTP route custom domains must use binding_type Disabled, Auto, or SniEnabled, and SniEnabled requires certificate_id (or certificate_config on this module)."
  }

  validation {
    condition = alltrue(flatten([
      for route_config in values(var.http_route_configs) : [
        for rule in route_config.rules : [
          for target in rule.targets : (
            try(target.weight, null) == null ? true : (
              target.weight >= 0
              && target.weight <= 100
              && floor(target.weight) == target.weight
            )
          )
        ]
      ]
    ]))
    error_message = "HTTP route target weights must be whole numbers between 0 and 100."
  }
}

variable "logs_destination" {
  type        = string
  description = "Where Container Apps Env sends logs: log-analytics (direct) or azure-monitor (via diagnostic settings) or none."
  default     = "log-analytics"

  validation {
    condition     = contains(["log-analytics", "azure-monitor", "none"], var.logs_destination)
    error_message = "logs_destination must be one of: log-analytics, azure-monitor, none."
  }
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
