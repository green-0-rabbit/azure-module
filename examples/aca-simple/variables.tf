variable "rg_prefix" {
  type    = string
  default = "preview"
}

variable "location" {
  default = "westeurope"
}

variable "subscription_id" {}

variable "ip_restrictions" {
  type = set(object({
    address : string
    name : string
  }))
  default = []
}

variable "tenant_id" {
  type    = string
  default = ""
}

variable "project" {
  type        = string
  description = "Project name for tagging and naming."
}

variable "env" {
  type        = string
  description = "Deployment environment name for tagging."
  default     = "preview"
}

variable "private_dns_zone_name" {
  type        = string
  description = "Custom private DNS zone name."
  default     = ""
}

variable "route_custom_domain_name" {
  type        = string
  description = "Optional environment route custom domain FQDN (for example, approuter-preview.internal.example.com)."
  default     = ""
}

variable "route_custom_domain_certificate_blob_base64" {
  type        = string
  description = "Base64 encoded PFX certificate for the route custom domain."
  default     = ""
  sensitive   = true
}

variable "route_custom_domain_certificate_password" {
  type        = string
  description = "Password for the route custom domain PFX certificate."
  default     = ""
  sensitive   = true
}

variable "spoke_vnet_name" {
  description = "The name of the spoke virtual network."
  type        = string
}

variable "spoke_vnet_address_space" {
  description = "The address space for the spoke virtual network."
  type        = list(string)
  default     = ["10.2.0.0/16"]
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

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}

variable "app_port" {
  description = "Application port for the todo-api container."
  type        = string
  default     = "3001"
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = null
  nullable  = true
}

variable "remote_acr_config" {
  type = object({
    username = string
    fqdn     = string
    images   = list(string)
  })
  default  = null
  nullable = true
}

variable "remote_acr_password" {
  type      = string
  sensitive = true
  default   = null
  nullable  = true
}

variable "devbox_admin_password_secret_name" {
  type        = string
  description = "Key Vault secret name for the generated Windows DevBox admin password."
  default     = "devbox-admin-password"
}

variable "aca_private_endpoint_ip" {
  description = "Static IP address for the ACA Private Endpoint."
  type        = string
}

