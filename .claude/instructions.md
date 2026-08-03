# Terraform Instructions

This repository is module-focused. Terraform operations must be executed through the root `justfile`.

## Required Behavior

- When a Terraform task is requested, use `just` recipes from `justfile`.
- Do not run direct `terraform` commands when an equivalent `just` recipe exists.
- Run commands from the repository root (the directory containing `justfile`).

## Supported Terraform Recipes

- Format all Terraform files: `just tf-fmt`
- Initialize a module target: `just tf-init <target>`
- Validate a module target: `just tf-validate <target>`

`<target>` is a module directory in this repository (for example: `acr`).

## Example Deployment Recipes

- Initialize an example: `just tf-init-ex <example>`
- Plan an example: `just tf-plan-ex <example>`
- Apply an example: `just tf-apply-ex <example>`
- Destroy an example: `just tf-destroy-ex <example>`

`<example>` is a directory name under `examples/` (for example: `todo-api`). Plan, apply, and destroy automatically use `dev.tfvars`. Extra arguments can be appended (e.g. `just tf-plan-ex todo-api -var="admin_password=..."`).

## Examples

- `just tf-init acr`
- `just tf-validate acr`
- `just tf-init-ex todo-api`
- `just tf-plan-ex todo-api`

## Notes

- If initialization is required before validation, run `tf-init` first for the same target.
- Keep commands scoped to the requested target module.
- The example recipes read `ARM_SUBSCRIPTION_ID` and `TF_VAR_admin_password` from the shell environment. Load them with `glb-var dev` in the same shell invocation as the recipe; the recipes fail fast with a clear message if either is unset.
