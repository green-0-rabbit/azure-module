location = "westeurope"
project  = "webapp-simple"
env      = "preview"

# Must be globally unique across Azure. Change before applying.
acr_name = "webappsimplepreviewacr"

hello_world_image = "hello-world:latest"
app_port          = "80"

spoke_vnet_name          = "webapp-simple"
spoke_vnet_address_space = ["10.3.0.0/16"]

spoke_vnet_subnets = {
  # Dedicated to the App Service Environment. Nothing else may live here.
  # /27 is the documented minimum and is fine for this demo's single I1v2 instance. Do not copy
  # this into production: 5 addresses are reserved for management and the platform uses 7 to 27
  # more, so a /27 leaves little or no room to scale out. Use /24 there, or /23 near max capacity.
  AseSubnet = {
    subnet_address_prefix = ["10.3.1.0/27"]
    delegation = {
      name = "ase-delegation"
      service_delegation = {
        name    = "Microsoft.Web/hostingEnvironments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }

  # Five addresses are reserved per subnet, so this leaves 27 usable. The demo places one private
  # endpoint here (the ACR), with room to add more without resizing.
  PrivateEndpointSubnet = {
    subnet_address_prefix                         = ["10.3.2.0/27"]
    private_link_service_network_policies_enabled = false
  }

  BastionSubnet = {
    subnet_address_prefix = ["10.3.3.0/24"]
  }
}

admin_username = "bastionadmin"

tags = {
  env     = "preview"
  project = "webapp-simple"
}
