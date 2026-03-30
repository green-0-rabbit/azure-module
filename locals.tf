locals {
  resource_name                = "${var.app_config.name}-${var.environment}"
  custom_domain_certificate_id = var.custom_domain != null ? try(var.custom_domain.certificate_id, null) : null
  custom_domain_binding_type   = var.custom_domain == null ? null : (local.custom_domain_certificate_id != null ? coalesce(try(var.custom_domain.certificate_binding_type, null), "SniEnabled") : "Disabled")
}
