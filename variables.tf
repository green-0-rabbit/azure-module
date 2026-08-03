variable "env" { type = string }

variable "name" {
  type        = string
  description = "Name of the App Service Plan. Used verbatim as the resource name."
}

variable "location" {
  type        = string
  description = "Azure region for the plan. When app_service_environment_id is set, this must match the region of the App Service Environment."
}

variable "resource_group_name" { type = string }

variable "os_type" {
  type        = string
  description = "Operating system for the plan: Linux, Windows, or WindowsContainer. Cannot be changed after creation."
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows", "WindowsContainer"], var.os_type)
    error_message = "os_type must be one of: Linux, Windows, WindowsContainer."
  }
}

variable "sku_name" {
  type        = string
  description = <<-EOT
    Plan SKU. Isolated v2 (I1v2 to I6v2) is only valid inside an App Service Environment, and an
    App Service Environment only accepts Isolated v2. Consumption, Elastic Premium and Workflow
    Standard SKUs are intentionally not accepted; this module targets web apps.
  EOT
  default     = "P1v3"

  validation {
    condition = contains([
      "F1", "D1",
      "B1", "B2", "B3",
      "S1", "S2", "S3",
      "P1v2", "P2v2", "P3v2",
      "P0v3", "P1v3", "P2v3", "P3v3",
      "P1mv3", "P2mv3", "P3mv3", "P4mv3", "P5mv3",
      "I1v2", "I2v2", "I3v2", "I4v2", "I5v2", "I6v2",
    ], var.sku_name)
    error_message = "sku_name must be one of the Free, Shared, Basic, Standard, Premium v2/v3/mv3 or Isolated v2 SKUs."
  }
}

variable "app_service_environment_id" {
  type        = string
  description = "Resource ID of an App Service Environment v3 to place this plan inside. Leave null for a multi-tenant plan. Requires an Isolated v2 sku_name."
  default     = null
}

variable "worker_count" {
  type        = number
  description = "Number of workers (instances) allocated to the plan. Leave null to let Azure apply the SKU default."
  default     = null
}

variable "per_site_scaling_enabled" {
  type        = bool
  description = "Allow apps on this plan to scale independently of each other."
  default     = false
}

variable "zone_balancing_enabled" {
  type        = bool
  description = "Spread workers across availability zones. Requires a region with zones and a SKU that supports zone redundancy; worker_count must be high enough to cover the zones."
  default     = false
}

variable "maximum_elastic_worker_count" {
  type        = number
  description = "Maximum number of workers for elastic scale. Only meaningful on plans that support elastic scaling."
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
