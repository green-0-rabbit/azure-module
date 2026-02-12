variable "acr_name" {
  description = "ACR name (globally unique, 5-50 alphanumeric)"
  type        = string
}

variable "env" {
  description = "Environment name, e.g. dev, prod. Used for tagging and naming."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will host the ACR"
  type        = string
}

variable "location" {
  description = "Azure location, e.g. westeurope"
  type        = string
}

variable "sku" {
  description = "ACR SKU (Premium required if a Private Endpoint is attached later)"
  type        = string
  default     = "Premium"
}

variable "tags" {
  description = "Tags to apply to ACR and DNS resources"
  type        = map(string)
  default     = {}
}

# --- Private DNS zone for ACR Private Link ---

variable "create_private_link_dns_zone" {
  description = "Create the privatelink.azurecr.io Private DNS zone"
  type        = bool
  default     = true
}

variable "vnet_ids" {
  description = "List of VNet IDs to link to the privatelink.azurecr.io zone"
  type        = list(string)
  default     = []
}

variable "dns_link_name_prefix" {
  description = "Prefix used for DNS VNet link names"
  type        = string
  default     = "link"
}

variable "public_access_enabled" {
  type        = bool
  description = "Enable public network access for the ACR"
  default     = false
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


