variable "key_vault_name" {
  description = "Key Vault name (globally unique)"
  type        = string
}

variable "env" {
  description = "Environment name, e.g. dev, prod. Used for naming."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will host the Key Vault"
  type        = string
}

variable "location" {
  description = "Azure location, e.g. westeurope"
  type        = string
}

variable "sku_name" {
  description = "Key Vault SKU name"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], lower(var.sku_name))
    error_message = "sku_name must be either standard or premium"
  }
}

variable "public_network_access_enabled" {
  description = "Enable public network access for the Key Vault"
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Key Vault firewall rules configuration"
  type = object({
    default_action             = string
    bypass                     = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default  = null
  nullable = true

  validation {
    condition = var.network_acls == null || contains([
      "Allow",
      "Deny"
    ], var.network_acls.default_action)
    error_message = "network_acls.default_action must be either Allow or Deny"
  }

  validation {
    condition = var.network_acls == null || contains([
      "AzureServices",
      "None"
    ], var.network_acls.bypass)
    error_message = "network_acls.bypass must be either AzureServices or None"
  }
}

variable "rbac_authorization_enabled" {
  description = "Enable RBAC authorization for the Key Vault"
  type        = bool
  default     = false
}

variable "purge_protection_enabled" {
  description = "Enable purge protection for the Key Vault"
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Number of retention days for soft-deleted vaults"
  type        = number
  default     = 90
}

variable "tags" {
  description = "Tags to apply to Key Vault resources"
  type        = map(string)
  default     = {}
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
