variable "subscription_id" {}

variable "location" {
  type        = string
  description = "Azure region. Must support App Service Environment v3 and Isolated v2."
  default     = "westeurope"
}

variable "project" {
  type        = string
  description = "Project name for tagging and naming."
}

variable "env" {
  type        = string
  description = "Deployment environment name."
  default     = "preview"
}

variable "ase_domain_suffix" {
  type        = string
  description = "Domain the App Service Environment's DNS suffix sits under. Differs by cloud, for example appserviceenvironment.us in Azure Government."
  default     = "appserviceenvironment.net"
}

variable "acr_name" {
  type        = string
  description = "ACR name. Globally unique, 5-50 alphanumeric characters."
}

variable "hello_world_image" {
  type        = string
  description = "Image and tag to run, as stored in the ACR. Import it before applying; see README.md."
  default     = "hello-world:latest"
}

variable "app_port" {
  type        = string
  description = "Port the container listens on. App Service needs this told to it explicitly for custom containers."
  default     = "80"
}

variable "spoke_vnet_name" {
  type        = string
  description = "The name of the spoke virtual network."
}

variable "spoke_vnet_address_space" {
  type        = list(string)
  description = "The address space for the spoke virtual network."
  default     = ["10.3.0.0/16"]
}

variable "spoke_vnet_subnets" {
  description = "Subnets to create inside the spoke virtual network. AseSubnet must be delegated to Microsoft.Web/hostingEnvironments."
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
  }))
}

variable "admin_username" {
  type        = string
  description = "Admin username for the bastion VM used to reach the private app."
}

variable "admin_password" {
  type      = string
  sensitive = true
  default   = null
  nullable  = true
}

variable "tags" {
  type        = map(string)
  description = "Common tags applied to resources."
  default     = {}
}
