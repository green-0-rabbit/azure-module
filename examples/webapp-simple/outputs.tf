output "acr_login_server" {
  description = "ACR login server. Import the image here before applying the web app."
  value       = module.acr.login_server
}

output "ase_dns_suffix" {
  description = "DNS suffix of the App Service Environment"
  value       = module.app_service_environment.dns_suffix
}

output "ase_ilb_ip" {
  description = "Internal load balancer IP every app in the environment resolves to"
  value       = local.ase_ilb_ip
}

output "webapp_hostname" {
  description = "Hostname of the web app. Resolves only from inside the VNet."
  value       = module.hello_world.default_hostname
}

output "webapp_url" {
  description = "URL to curl from the bastion VM"
  value       = "https://${module.hello_world.default_hostname}"
}

output "key_vault_uri" {
  description = "Key Vault the app resolves its DEMO_SECRET reference from"
  value       = module.keyvault.vault_uri
}

output "webapp_principal_id" {
  description = "Principal ID of the app identity holding AcrPull on the registry"
  value       = module.hello_world.principal_id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion VM, used by the vm-exec-example recipe"
  value       = module.bastion_vm.vm_public_ip
}

output "bastion_private_ip" {
  value = module.bastion_vm.bastion_private_ip
}
