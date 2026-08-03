locals {
  resource_name                = "${var.app_config.name}-${var.environment}"
  custom_domain_certificate_id = var.custom_domain != null ? try(var.custom_domain.certificate_id, null) : null
  custom_domain_binding_type   = var.custom_domain == null ? null : (local.custom_domain_certificate_id != null ? coalesce(try(var.custom_domain.certificate_binding_type, null), "SniEnabled") : "Disabled")

  # Deliberately does not test acr_id: callers pass module.acr.id, which is unknown until the
  # registry exists, and Terraform cannot size a count from an unknown value. Whether acr_id is
  # required is enforced by the validation on var.acr_config instead.
  use_acr_managed_identity   = var.acr_config != null && try(var.acr_config.use_managed_identity, true)
  create_acr_role_assignment = local.use_acr_managed_identity && try(var.acr_config.create_role_assignment, true)
}
