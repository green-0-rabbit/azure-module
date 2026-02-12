variable "app_config" {
  type = object({
    name                         = optional(string, "default-app")
    revision_mode                = optional(string, "Single")
    workload_profile_name        = optional(string, "Consumption")
    container_app_environment_id = string
  })
  validation {
    condition = var.app_config == null ? true : try(
      contains(["Single", "Multiple"], var.app_config.revision_mode),
      true
    )
    error_message = "revision_mode must be either \"Single\" or \"Multiple\"."
  }
}
variable "environment" { type = string }
variable "location" {
  type        = string
  description = "Azure region for the environment (must be Switzerland North/West)."
  validation {
    condition     = contains(["switzerlandnorth", "switzerlandwest", "eastus", "westeurope"], var.location)
    error_message = "location must be one of: switzerlandnorth, switzerlandwest, eastus, westeurope."
  }
}
variable "resource_group_name" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
variable "ingress" {
  type = object({
    allow_insecure_connections = optional(bool, false)
    external_enabled           = optional(bool, false)
    target_port                = optional(number, 8080)
    transport                  = optional(string, "auto")
    client_certificate_mode    = optional(string, "ignore")
    traffic_weight = optional(list(object({
      latest_revision = optional(bool, true)
      percentage      = optional(number, 100)
      label           = optional(string)
      })), [{
      latest_revision = true
      percentage      = 100
    }])
  })
  default = null

  validation {
    condition = var.ingress != null && (
      contains(["require", "accept", "ignore"], coalesce(var.ingress.client_certificate_mode, "ignore")) &&
      contains(["auto", "http", "http2", "tcp"], coalesce(var.ingress.transport, "auto"))
    )
    error_message = "Ingress is misconfigured: client_certificate_mode must be one of require/accept/ignore and transport must be one of auto/http/http2/tcp."
  }
}

variable "custom_domain" {
  description = "Custom domain configuration for the container app"
  type = object({
    name                     = string
    certificate_id           = optional(string)
    certificate_binding_type = optional(string)
  })
  default = null
}

variable "template" {
  type = object({
    containers = list(object({
      name    = string
      image   = string
      cpu     = optional(number, 0.25)
      memory  = optional(string, "0.5Gi")
      command = optional(list(string))
      args    = optional(list(string))
      env = optional(list(object({
        name        = string
        value       = optional(string)
        secret_name = optional(string)
      })), [])
      volume_mounts = optional(list(object({
        name = string
        path = string
      })), [])
      liveness_probe = optional(object({
        failure_count_threshold = optional(number)
        header = optional(list(object({
          name  = string
          value = string
        })), [])
        host             = optional(string)
        initial_delay    = optional(number, 15)
        interval_seconds = optional(number, 10)
        path             = optional(string)
        port             = number
        timeout          = optional(number, 5)
        transport        = string
      }))
      readiness_probe = optional(object({
        failure_count_threshold = optional(number)
        header = optional(list(object({
          name  = string
          value = string
        })), [])
        host                    = optional(string)
        interval_seconds        = optional(number, 10)
        path                    = optional(string)
        port                    = number
        success_count_threshold = optional(number, 3)
        timeout                 = optional(number, 5)
        transport               = string
      }))
      startup_probe = optional(object({
        failure_count_threshold = optional(number)
        header = optional(list(object({
          name  = string
          value = string
        })), [])
        host             = optional(string)
        interval_seconds = optional(number, 10)
        path             = optional(string)
        port             = number
        timeout          = optional(number, 5)
        transport        = string
      }))
    }))
    min_replicas = optional(number, 0)
    max_replicas = optional(number, 10)
    volumes = optional(list(object({
      name         = string
      storage_type = optional(string, "EmptyDir")
      storage_name = optional(string)
    })), [])
  })
  validation {
    condition     = var.template != null && length(var.template.containers) > 0
    error_message = "The template object must be provided with at least one container definition."
  }
}

variable "acr_config" {
  description = "Configuration for the Azure Container Registry, including its FQDN, Resource ID, and whether to create AcrPull role assignment."
  type = object({
    registry_fqdn          = string
    acr_id                 = string
    create_role_assignment = optional(bool, true)
  })
  default = null
}

variable "kv_config" {
  description = "Configuration for Key Vault integration, including Key Vault Resource ID and whether to create Key Vault Secrets User role assignment."
  type = object({
    kv_id                  = string
    create_role_assignment = optional(bool, true)
  })
  default = null
}

variable "auth" {
  description = "Authentication configuration for the Container App."
  type = object({
    identity_providers = optional(object({
      azure_active_directory = optional(object({
        registration = object({
          client_id                  = string
          client_secret_setting_name = optional(string)
        })
        tenant_id = optional(string)
      }))
      custom_open_id_connect_providers = optional(map(object({
        enabled = optional(bool, true)
        registration = object({
          client_id = string
          client_credential = optional(object({
            method                     = optional(string)
            client_secret_setting_name = optional(string)
          }))
          open_id_connect_configuration = optional(object({
            authorization_endpoint           = optional(string)
            token_endpoint                   = optional(string)
            issuer                           = optional(string)
            certification_uri                = optional(string)
            well_known_open_id_configuration = optional(string)
          }))
        })
        login = optional(object({
          name_claim_type = optional(string)
          scopes          = optional(list(string))
        }))
      })))
    }))
    global_validation = optional(object({
      unauthenticated_client_action = optional(string, "RedirectToLoginPage")
      excluded_paths                = optional(list(string), [])
    }))
  })
  default = null
}

variable "secrets" {
  type = list(object({
    name                = string
    value               = optional(string)
    key_vault_secret_id = optional(string)
    identity            = optional(string)
  }))
  default     = []
  description = "List of secrets to be used by the Container App. Can be a value or a Key Vault reference."
}
