# Azure Module

Reusable Terraform modules for Azure infrastructure.

## Available Modules

| Module | Description |
|--------|-------------|
| `aca` | Azure Container App |
| `acaenv` | Azure Container App Environment |
| `acr` | Azure Container Registry |
| `aifoundry` | Azure AI Foundry (OpenAI) |
| `devbox` | Windows 11 Development VM with WSL bootstrap and Bastion |
| `keyvault` | Azure Key Vault |
| `pgflexserver` | Azure PostgreSQL Flexible Server |
| `storageaccount` | Azure Storage Account |
| `vnet` | Virtual Network with subnets, NSGs, and DNS zone linking |

## Using Modules with Git Tags

Reference any module directly from a tagged release:

```hcl
module "vnet" {
  source = "git::https://github.com/green-0-rabbit/azure-module.git//vnet?ref=v1.0.0"

  resource_group_name = azurerm_resource_group.rg.name
  location            = "westeurope"
  vnet_name           = "my-vnet"
  vnet_address_space  = ["10.0.0.0/16"]

  subnets = {
    AppSubnet = {
      subnet_address_prefix = ["10.0.1.0/24"]
    }
  }
}
```

The source format is:

```
git::https://github.com/green-0-rabbit/azure-module.git//<module>?ref=<tag>
```

Replace `<module>` with a module name from the table above and `<tag>` with the desired version (e.g. `v1.0.0`).

### SSH variant

```hcl
source = "git::git@github.com:green-0-rabbit/azure-module.git//vnet?ref=v1.0.0"
```

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.1.0
- [just](https://github.com/casey/just) command runner
- Azure CLI (`az`) logged in to the target subscription

## Running Examples Locally

The `examples/` directory contains ready-to-deploy projects that wire the modules together. All examples are driven through `just` recipes from the repo root.

### 1. Clone and enter the repository

```bash
git clone https://github.com/green-0-rabbit/azure-module.git
cd azure-module
```

### 2. Authenticate to Azure

```bash
az login
az account set --subscription <SUBSCRIPTION_ID>
```

### 3. Review the variables file

Each example ships a `dev.tfvars` with sensible defaults. Open it and adjust values to match your environment:

```bash
$EDITOR examples/todo-api/dev.tfvars
```

Key values to review:

| Variable | Description |
|----------|-------------|
| `resource_group_name` | Resource group that will be created |
| `acr_name` | Existing Azure Container Registry name |
| `acr_resource_group_name` | Resource group of the ACR |
| `spoke_vnet_address_space` | VNet CIDR (avoid collisions with existing networks) |
| `windows_devbox_custom_image_id` | Custom VM image (set to `null` for marketplace default) |

### 4. Initialize, plan, and apply

```bash
# Initialize providers and modules
just tf-init-ex todo-api

# Preview the changes
just tf-plan-ex todo-api

# Deploy
just tf-apply-ex todo-api

# Tear down when done
just tf-destroy-ex todo-api
```

On the first run, you will be prompted to enter an `admin_password`. The value is saved to `examples/.env` (git-ignored) and reused on subsequent runs.

### Passing extra arguments

All example recipes accept trailing arguments forwarded to Terraform:

```bash
# Target a single resource
just tf-plan-ex todo-api -target=module.vnet_spoke

# Auto-approve apply
just tf-apply-ex todo-api -auto-approve
```

## Module Development

```bash
# Format all Terraform files
just tf-fmt

# Initialize a module (downloads providers for validation)
just tf-init <module>

# Validate a module
just tf-validate <module>
```

Example:

```bash
just tf-init vnet
just tf-validate vnet
```
