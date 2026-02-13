locals {
  networking = {
    subnet_id          = trimspace(var.networking.subnet_id)
    enable_public_ip   = var.networking.enable_public_ip
    virtual_network_id = try(trimspace(var.networking.virtual_network_id), null)
  }
}
