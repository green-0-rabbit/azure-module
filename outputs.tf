output "frontend_fqdn" {
  value       = module.frontend_app.app_fqdn
  description = "FQDN of the frontend Container App."
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