# azure-module

Reusable Terraform modules for Azure. Each top-level directory is an independently versioned
module, released by git tag (`vnet/v1.0.0`) via `techpivot/terraform-module-releaser`.

## Running Terraform

**Always use `just` recipes. Never run `terraform` directly when a recipe exists.** Run from the
repository root.

| Task | Command |
|---|---|
| Format everything | `just tf-fmt` |
| Init a module | `just tf-init <module>` |
| Validate a module | `just tf-validate <module>` |
| Init an example | `just tf-init-ex <example>` |
| Plan an example | `just tf-plan-ex <example>` |
| Apply an example | `just tf-apply-ex <example>` |
| Destroy an example | `just tf-destroy-ex <example>` |
| Import into example state | `just tf-import-ex <example> <address> <id>` |

Example recipes use `dev.tfvars` automatically and accept trailing arguments:
`just tf-plan-ex todo-api -target=module.vnet_spoke`.

### Load environment variables first

`glb-var` is a **shell function**, so it must run in the same shell invocation as the recipe:

```bash
glb-var dev && just tf-plan-ex webapp-simple
```

The recipes read everything from the shell environment — nothing is sourced from a file. They need
at least `ARM_SUBSCRIPTION_ID` and `TF_VAR_admin_password`; `require-env` stops with instructions
if either is missing, rather than failing later inside Terraform or SSH.

Because `glb-var` is a shell function and shell state does not persist between commands, chaining
it with `&&` is required — running it as a separate step has no effect on the recipe.

### Running commands on the bastion VM

Private examples are only reachable from inside the VNet. To curl an endpoint or check DNS:

```bash
glb-var dev && just vm-exec-example '<example>' '<command>'
```

Quote the command so the local shell does not expand it. The recipe reads the example's
`bastion_public_ip` output, so every private example must expose one.

## Module conventions

Split files by concern: `main.tf`, `variables.tf`, `outputs.tf`, `locals.tf`, `versions.tf`, plus
`network_pe.tf` for private endpoints and `managed_identity.tf` for identities and role assignments.

- **Naming.** `local.resource_name = "${lower(var.name)}-${var.env}"`. App-tier modules (`aca`,
  `webapp`) use it as the resource name; environment-tier modules (`acaenv`, `appserviceenv`) take
  `var.name` verbatim. `local.tags = merge({ "ResourceName" = local.resource_name }, var.tags)`.
- **`env`, not `environment`.** `aca` is the lone exception.
- **Grouped inputs.** Related settings go in one object variable (`app_config`, `acr_config`,
  `kv_config`, `networking`, `dns`) rather than many flat variables.
- **Optional features are null-by-default.** Gate them with a `local.enable_*` derived from whether
  the object was supplied.
- **Validation lives in `variable` blocks.** Use `lifecycle.precondition` only for rules spanning
  two variables, since cross-variable `validation` needs Terraform >= 1.9 and modules declare 1.1.0.
- **Private endpoints** reuse the shared shape in any `network_pe.tf`: `var.networking` +
  `var.dns`, both nullable, with null-safe fallback objects in `locals.tf`.
- **Additive by default.** These modules are consumed by tag. New inputs and outputs should not
  break existing callers; a narrowed provider constraint or a renamed input needs a major tag.

## Provider constraints

Pin with `~>`, not an open `>=`. `>= 4.50.0` is unbounded and resolves azurerm 5.x today, while the
examples are capped in 4.x — modules then get validated against a different major than they are
used at. Use `~> 4.50` (any 4.x from 4.50), never `~> 4.50.0`, which pins to a single minor and is
what broke the examples when `acaenv` needed 4.68.

Verify a floor before declaring it. Pin the version, `init -upgrade`, and validate.

## Gotchas

- **`for_each` keys must be known at plan time.** The `vnet` module links DNS zones with
  `for_each = toset(var.private_dns_zone_names)`, so a zone name taken from a computed attribute
  fails with `Invalid for_each argument`. Compose such names from inputs instead, and assert the
  result with a `check` block.
- **`coalesce` errors when every argument is null.** Use an explicit conditional. `aca/locals.tf`
  has the safe idiom; `acaenv/locals.tf` currently has the broken one.
- **CI does not validate examples.** `dir_names_max_depth: 1` collapses `examples/<name>` to
  `examples`, which holds no `.tf` files and validates trivially. Validate examples locally.
