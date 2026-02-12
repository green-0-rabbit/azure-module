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

## Examples

- `just tf-init acr`
- `just tf-validate acr`

## Notes

- If initialization is required before validation, run `tf-init` first for the same target.
- Keep commands scoped to the requested target module.