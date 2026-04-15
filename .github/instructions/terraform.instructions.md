---
applyTo: "**"
---
# Terraform Instructions

This repository is module-focused. Terraform operations must be executed through the root [justfile](../../justfile).

## Required Copilot Behavior

- When a Terraform task is requested, use `just` recipes from [justfile](../../justfile).
- Do not run direct `terraform` commands when an equivalent `just` recipe exists.
- Run commands from the repository root (the directory containing [justfile](../../justfile)).

## Supported Terraform Recipes

- Format all Terraform files: `just tf-fmt`
- Initialize a module target: `just tf-init <target>`
- Validate a module target: `just tf-validate <target>`

`<target>` is a module directory in this repository (for example: `acr`).

## Example Deployment Recipes

1. **Load Environment Variables:** Run `glb-var dev` to load the necessary environment variables.

2. **Run Terraform Commands:**
   - **Init:** ``just tf-init-ex <example>`(eg aca-simple)`
   - **Plan:** `just tf-plan-ex <example>`
   - **Apply:** `just tf-apply-ex <example>`

`<example>` is a directory name under `examples/` (for example: `todo-api`). Plan and apply automatically use `dev.tfvars`. Extra arguments can be appended (e.g. `just tf-plan-ex todo-api -var="admin_password=..."`).

## Examples

- `just tf-init acr`
- `just tf-validate acr`

## Importing Existing Resources into Terraform State

When a resource already exists in Azure but is missing from Terraform state (for example after provider inconsistency errors), use the `just` import recipes instead of running raw `terraform import` commands.

1. **Load Environment Variables** first:
   - Development: `glb-var dev`

2. **Use Import Recipes:**
   - **Development Import:** `just tf-import-ex <example> <resource_address> <resource_id>`

3. **Then Reconcile State:**
   - Run plan/apply again using the standard commands.

### Examples
- `glb-var dev && just tf-import-ex aca-simple azurerm_private_endpoint.aca "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateEndpoints/<name>"`


## Notes

- If initialization is required before validation, run `tf-init` first for the same target.
- Keep commands scoped to the requested target module.