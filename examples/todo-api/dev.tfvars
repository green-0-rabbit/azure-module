location            = "westeurope"
resource_group_name = "dev-todoapi-rg"
project             = "dev-todoapi"

env = "dev"

#### VM variables
admin_username = "bastionadmin"

#### ACR
acr_name = "devinfraacr"

#### Private DNS zone
private_dns_zone_name = "dev-example.io"

#### Key Vault
key_vault_name = "kv-dev-todoapi-dev"

#### Storage
storage_account_name   = "devtodoapisa"
storage_container_name = "todo-app-container"

#### PostgreSQL
postgres_administrator_login = "psqladmin"

#### App
app_port = "3001"

##### Spoke vNet variables
spoke_vnet_name          = "spoke-todoapi"
spoke_vnet_address_space = ["10.2.0.0/16"]
spoke_vnet_subnets = {
  ACASubnet = {
    subnet_address_prefix = ["10.2.6.0/23"]
    delegation = {
      name = "aca-delegation"
      service_delegation = {
        name    = "Microsoft.App/environments"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
    nsg_inbound_rules = {
      "Allow-HTTP-HTTPS" = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_ranges    = ["80", "443"]
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
      "Allow-ACA-Ports" = {
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "30000-32767"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
      "Deny-Internet-Inbound" = {
        priority                   = 4000
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        destination_port_range     = "*"
        source_port_range          = "*"
        source_address_prefix      = "Internet"
        destination_address_prefix = "*"
      }
    }
  }
  PrivateEndpointSubnet = {
    subnet_address_prefix = ["10.2.5.0/24"]
  }
  PostgresSubnet = {
    subnet_address_prefix = ["10.2.8.0/24"]
    service_endpoints     = ["Microsoft.Storage"]
    delegation = {
      name = "fs-delegation"
      service_delegation = {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
    nsg_inbound_rules = {
      "Allow-Postgres" = {
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "5432"
        source_address_prefix      = "VirtualNetwork"
        destination_address_prefix = "*"
      }
    }
  }
  MainSubnet = {
    subnet_address_prefix = ["10.2.1.0/24"]
  }
  AzureBastionSubnet = {
    subnet_address_prefix = ["10.2.3.0/26"]
  }
}

# Static IP for ACA Private Endpoint
aca_private_endpoint_ip = "10.2.5.10"

# Windows DevBox
enable_windows_devbox               = true
windows_devbox_vm_size              = "Standard_D2s_v3"
windows_devbox_custom_image_id      = "/subscriptions/64aff275-5209-47fd-88a0-f127dfab04b8/resourceGroups/dev-main-rg/providers/Microsoft.Compute/galleries/dev_devbox_gallery_example/images/windevbox/versions/0.0.3"
windows_devbox_enable_wsl_bootstrap = true
