location = "northeurope"
project  = "aca-simple"
env      = "preview"

tags = {
  env     = "preview"
  project = "aca-simple"
}

app_port = "8080"

aca_private_endpoint_ip = "10.1.6.10"

admin_username = "bastionadmin"

spoke_vnet_name          = "spoke-aca-simple"
spoke_vnet_address_space = ["10.1.0.0/16"]
spoke_vnet_subnets = {
  ACASubnet = {
    subnet_address_prefix = ["10.1.6.0/23"]
    delegation = {
      name = "aca-delegation"
      service_delegation = {
        name    = "Microsoft.App/environments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
  }
  PrivateEndpointSubnet = {
    subnet_address_prefix = ["10.1.5.0/24"]
  }
  BastionSubnet = {
    subnet_address_prefix = ["10.1.1.0/27"]
    nsg_inbound_rules = {
      "Allow-SSH-Trusted" = {
        priority                   = 200
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefixes    = ["0.0.0.0/0"]
        destination_address_prefix = "*"
      }
      "Allow-RDP-From-Bastion" = {
        priority                   = 210
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefixes    = ["0.0.0.0/0"]
        destination_address_prefix = "*"
      }
    }
  }
  AzureBastionSubnet = {
    subnet_address_prefix = ["10.1.4.0/26"]
  }
}
