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
