variable "env" { type = string }

variable "name" {
  type        = string
  description = "Name of the App Service Environment. Used verbatim as the resource name."
}

variable "resource_group_name" { type = string }

variable "subnet_id" {
  type        = string
  description = <<-EOT
    Dedicated subnet for the environment. It must be delegated to Microsoft.Web/hostingEnvironments
    and hold no other resources.

    Sizing: /27 (32 addresses) is the minimum Azure accepts, /24 (256) is recommended for production,
    and /23 (512) if you expect to scale near the 200 instance cap with frequent scale operations.
    Five addresses are reserved for management and the platform uses a further 7 to 27 for
    supporting infrastructure, so a /27 leaves very little room for App Service plan instances.
    Changing the subnet after creation requires a support ticket.

    The environment takes its region from this subnet, which is why the module has no location input.
  EOT
}

variable "internal_load_balancing_mode" {
  type        = string
  description = "Set to \"Web, Publishing\" for an internal (ILB) environment reachable only from the VNet, or \"None\" to expose it publicly."
  default     = "Web, Publishing"

  validation {
    condition     = contains(["None", "Web, Publishing"], var.internal_load_balancing_mode)
    error_message = "internal_load_balancing_mode must be either \"None\" or \"Web, Publishing\"."
  }
}

variable "zone_redundant" {
  type        = bool
  description = "Spread the environment across availability zones. Only available in regions that support zones, and cannot be changed after creation."
  default     = false
}

variable "dedicated_host_count" {
  type        = number
  description = "Number of dedicated hosts to reserve for the environment. Leave null unless you need host-level isolation."
  default     = null
}

variable "allow_new_private_endpoint_connections" {
  type        = bool
  description = "Allow new private endpoint connections to be created against this environment."
  default     = false
}

variable "remote_debugging_enabled" {
  type        = bool
  description = "Allow remote debugging against apps hosted in this environment."
  default     = false
}

variable "cluster_settings" {
  description = "Environment-level cluster settings, keyed by setting name (for example DisableTls1.0)."
  type        = map(string)
  default     = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
