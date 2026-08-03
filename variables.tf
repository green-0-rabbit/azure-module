variable "location" {
  description = "Azure region for deployed resources."
  type        = string
}

variable "project" {
  type        = string
  description = "Project name for tagging and naming."
}

variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
}

variable "env" {
  type        = string
  description = "Deployment environment (e.g., dev, staging, prod)."
  validation {
    condition     = contains(["dev", "staging", "prod"], var.env)
    error_message = "The 'env' variable must be one of: dev, staging, prod."
  }
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}

# ─── Private DNS zone name ────────────────────────────────────────────────────

variable "private_dns_zone_name" {
  type        = string
  description = "Custom private DNS zone name (e.g. dev-example.io)."
}

# ─── VNet / Spoke ─────────────────────────────────────────────────────────────

variable "spoke_vnet_name" {
  description = "The name of the spoke virtual network."
  type        = string
}

variable "spoke_vnet_address_space" {
  description = "The address space for the spoke virtual network."
  type        = list(string)
}

variable "spoke_vnet_subnets" {
  description = "Subnets to create inside the spoke virtual network."
  type = map(object({
    subnet_address_prefix                         = list(string)
    service_endpoints                             = optional(list(string), [])
    private_link_service_network_policies_enabled = optional(bool, true)
    firewall_enabled                              = optional(bool, false)
    delegation = optional(object({
      name = optional(string)
      service_delegation = optional(object({
        name    = optional(string)
        actions = optional(list(string))
      }))
    }))

    nsg_inbound_rules = optional(map(object({
      priority                   = number
      direction                  = optional(string, "Inbound")
      access                     = optional(string, "Allow")
      protocol                   = optional(string, "Tcp")
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      destination_port_ranges    = optional(set(string), [])
      source_address_prefix      = optional(string)
      source_address_prefixes    = optional(set(string), [])
      destination_address_prefix = optional(string)
      description                = optional(string)
    })), {})

    nsg_outbound_rules = optional(map(object({
      priority                   = number
      direction                  = optional(string, "Outbound")
      access                     = optional(string, "Allow")
      protocol                   = optional(string, "Tcp")
      source_port_range          = optional(string, "*")
      destination_port_range     = optional(string, "*")
      source_address_prefix      = optional(string)
      source_address_prefixes    = optional(set(string), [])
      destination_address_prefix = optional(string)
      description                = optional(string)
    })), {})
  }))
}

# ─── ACR ──────────────────────────────────────────────────────────────────────

variable "acr_name" {
  type        = string
  description = "Name of the Azure Container Registry."
}

# ─── Key Vault ────────────────────────────────────────────────────────────────

variable "key_vault_name" {
  type        = string
  description = "Name of the Azure Key Vault."
}

variable "key_vault_allowed_ip_ranges" {
  type        = list(string)
  default     = []
  description = "Allowed public CIDR ranges for Key Vault firewall (populate from automated Azure DevOps hosted-agent IP range updates)."
}

# ─── Storage Account ──────────────────────────────────────────────────────────

variable "storage_account_name" {
  type        = string
  description = "Name of the Azure Storage Account."
}

variable "storage_container_name" {
  description = "Storage container name for app assets."
  type        = string
}

# ─── PostgreSQL ───────────────────────────────────────────────────────────────

variable "postgres_administrator_login" {
  description = "The Administrator Login for the PostgreSQL Flexible Server."
  type        = string
}

# ─── App ──────────────────────────────────────────────────────────────────────

variable "app_port" {
  description = "Application port for the todo-api container."
  type        = string
  default     = "3001"
}

# ─── Secrets (sensitive) ──────────────────────────────────────────────────────

variable "admin_username" {
  type    = string
  default = "bastionadmin"
}

variable "admin_password" {
  type      = string
  sensitive = true
}

# ─── ACA Private Endpoint ────────────────────────────────────────────────────

variable "aca_private_endpoint_ip" {
  description = "Static IP address for the ACA Private Endpoint."
  type        = string
}

# ─── Windows DevBox ──────────────────────────────────────────────────────────

variable "enable_windows_devbox" {
  type        = bool
  default     = true
  description = "Enable Windows DevBox VM deployment."
}

variable "windows_devbox_vm_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "VM size for the Windows DevBox."
}

variable "windows_devbox_custom_image_id" {
  type        = string
  default     = null
  description = "Optional custom image ID for the Windows DevBox."
}

variable "windows_devbox_enable_wsl_bootstrap" {
  type        = bool
  default     = true
  description = "Run first-boot bootstrap to install VS Code, WSL Ubuntu, and base toolchain."
}

variable "windows_devbox_image_publisher" {
  type        = string
  default     = "MicrosoftWindowsDesktop"
  description = "Fallback marketplace image publisher."
}

variable "windows_devbox_image_offer" {
  type        = string
  default     = "windows-11"
  description = "Fallback marketplace image offer."
}

variable "windows_devbox_image_sku" {
  type        = string
  default     = "win11-25h2-pro"
  description = "Fallback marketplace image SKU."
}
