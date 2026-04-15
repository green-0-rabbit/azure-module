output "frontend_fqdn" {
  value       = module.frontend_app.app_fqdn
  description = "FQDN of the frontend Container App."
}

output "showcase_fqdn" {
  value       = module.showcase_app.app_fqdn
  description = "FQDN of the showcase Container App."
}

output "route_config_fqdn" {
  value       = try(module.container_app_environment.http_route_config_fqdns[local.route_config_name], null)
  description = "Environment-level route config FQDN used for path-based routing validation."
}

output "route_custom_domain_name" {
  value = (
    var.route_custom_domain_name != ""
    && nonsensitive(var.route_custom_domain_certificate_blob_base64) != ""
  ) ? var.route_custom_domain_name : null
  description = "Configured custom domain for the environment route config when enabled."
}

output "container_app_environment_id" {
  value       = module.container_app_environment.id
  description = "ID of the Container App Environment."
}

output "bastion_public_ip" {
  value = module.bastion_vm.vm_public_ip
}

output "bastion_private_ip" {
  value = module.bastion_vm.bastion_private_ip
}