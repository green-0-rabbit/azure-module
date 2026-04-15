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

## ACA Environment Rule-Based Routing

The `acaenv` module supports optional environment-level HTTP route configs through AzAPI using `Microsoft.App/managedEnvironments/httpRouteConfigs@2024-10-02-preview`. This feature is fully opt-in through `http_route_configs`; leaving the input empty creates no additional resources.

Use a map keyed by the route config child resource name so Terraform keeps stable identities:

```hcl
module "container_app_environment" {
  source = "git::https://github.com/green-0-rabbit/azure-module.git//acaenv?ref=v1.0.0"

  # existing required inputs omitted for brevity

  http_route_configs = {
    approuter = {
      custom_domains = [
        {
          name           = "apps.example.com"
          binding_type   = "SniEnabled"
          certificate_id = module.container_app_environment.certificate_id
        }
      ]
      rules = [
        {
          description = "Frontend traffic"
          routes = [
            {
              match = {
                prefix = "/frontend"
              }
              action = {
                prefix_rewrite = "/"
              }
            }
          ]
          targets = [
            {
              container_app = "frontend-app"
            }
          ]
        }
        {
          description = "API traffic"
          routes = [
            {
              match = {
                path_separated_prefix = "/api"
              }
            }
          ]
          targets = [
            {
              container_app = "api-app"
              weight        = 100
            }
          ]
        }
      ]
    }
  }
}
```

Notes and limitations:

- Route config names must be 3-63 characters and match `^[a-z][a-z0-9]*$`.
- `binding_type` supports `Disabled`, `Auto`, and `SniEnabled`. If you omit it, the module follows the existing custom-domain behavior in this repo: `SniEnabled` when `certificate_id` is set, otherwise `Disabled`.
- `SniEnabled` requires an environment certificate ID. You can reuse `acaenv.certificate_id` or pass an existing environment certificate ID.
- DNS ownership verification, DNS records, and managed certificate lifecycle are out of scope for this module.
- Do not bind the same hostname both as an environment-level route custom domain and as an app-level custom domain in the `aca` module.
- The feature uses a preview ARM API and may drift as Azure changes the contract.

Validation harness:

- `examples/aca-simple` now deploys two container apps and one environment route config.
- After `just tf-apply-ex aca-simple`, retrieve the route FQDN with `terraform -chdir=examples/aca-simple output -raw route_config_fqdn`.
- Because the example environment is private, verify routing from the bastion VM or another host in the VNet. For example, after loading env vars with `glb-var dev`, run `just vm-exec-example 'aca-simple' 'curl -I http://$(terraform -chdir=examples/aca-simple output -raw route_config_fqdn)/frontend'` and repeat with `/showcase` or `/sample/hello`.
- For custom domains, create the required DNS validation records first and ensure the environment certificate already exists before using `SniEnabled`.
