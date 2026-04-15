# Specification: Add Rule-Based Routing Support to the ACA Environment Module

## 1. Summary [Core]
- Change type: Module enhancement
- Goal: Add optional Azure Container Apps environment-level rule-based routing and route-level custom domain support to the module by using AzAPI, without changing behavior for existing module consumers.
- Why: Azure Container Apps supports `managedEnvironments/httpRouteConfigs`, but there is no native `azurerm` resource for this capability. The module currently supports the environment itself and optional environment certificates, but not environment-level route configuration.
- Scope: Add new optional module inputs, implement one or more HTTP route config child resources under the Container Apps environment, expose useful outputs, document the feature, and provide a dedicated validation example.
- Out of scope: DNS record creation, automatic managed certificate creation, automatic migration from existing app-level custom domains, creation of target container apps, and any breaking redesign of the current module interface.

## 2. Context [Core]
- Current state: The module creates an Azure Container Apps environment, optional environment certificate upload, diagnostics, and optional private endpoint support. The repository already depends on `azapi`, and other modules already use `azapi_resource` patterns for unsupported ARM resources. The container app module already supports app-level custom domains.
- Relevant area: The ACA environment module input schema, resource creation logic, outputs, example configuration, and module documentation.
- Existing pattern to follow: Reuse the repository's current AzAPI implementation style for unsupported Azure resources. Keep new features optional and additive. Continue exposing environment certificate IDs so callers can reuse them.
- Existing validation harness: `/Users/kennethag/projects/azure-module/examples/aca-simple` contains runnable Terraform configuration for the ACA environment and ACA modules and should be used as the validation harness if no end-to-end framework is available.
- Relevant references: Azure Container Apps rule-based routing documentation, Azure Container Apps route custom domain documentation, and the ARM resource definition for `Microsoft.App/managedEnvironments/httpRouteConfigs@2024-10-02-preview`.
- Assumptions: Target container apps already exist or are created outside this module. Target container apps are referenced by name. DNS validation records and any required certificate provisioning are handled outside this feature. Existing module consumers must continue to work unchanged when the new feature is not configured.
- Constraints already known: There is no native `azurerm` resource for HTTP route configs. The ARM API is preview-only. Route configs are environment child resources. A hostname used for environment-level route-based routing must not also be bound through app-level custom domain configuration.

## 3. Deliverables [Core]
- Code or config to add or update:
  - Optional input for HTTP route configurations.
  - AzAPI child resource implementation for environment-level route configs.
  - New outputs for route config resource identifiers and relevant computed values.
- Documentation to add or update:
  - Update module documentation for rule-based routing only if this repo has an established place for module feature documentation.
  - If no standard documentation surface exists for this kind of module enhancement, explicitly record that no doc update is required rather than creating a new documentation surface just for this feature.
  - If documentation is updated, include custom domain prerequisites, limitations, and guidance on coexistence with the existing app-level custom domain feature.
- Tests, validation, or checks to add or update:
  - Module validation for the ACA environment module.
  - Use `/Users/kennethag/projects/azure-module/examples/aca-simple` as the validation harness if no end-to-end framework is available, and extend it as needed to demonstrate routing between at least two container apps.
  - Documentation-backed manual verification steps for path-based routing and custom domain routing.
- Operational changes or setup required:
  - External DNS records for custom domains.
  - Environment certificate availability when `SniEnabled` is used.
  - Provider registration and Azure subscription readiness for the preview API.

## 4. Functional Requirements [Core]
- Must:
  - Expose an optional input that allows callers to define one or more environment-level HTTP route configurations.
  - Create `Microsoft.App/managedEnvironments/httpRouteConfigs@2024-10-02-preview` child resources under the Container Apps environment by using AzAPI.
  - Keep the feature fully opt-in so existing callers see no change when the new input is omitted or empty.
  - Support route rules with one or more route matches and one or more targets.
  - Support the Azure match fields needed by the feature: exact path, prefix, path-separated prefix, and case sensitivity when provided.
  - Support prefix rewrite actions when provided.
  - Support target container app names and optional target revision, label, and weight fields.
  - Support route-level custom domains with `Disabled`, `Auto`, and `SniEnabled` binding types.
  - Allow `certificate_id` to reference an environment certificate created by the module or an existing environment certificate provided by the caller.
  - Export route config identifiers and names. Export FQDNs as well if the API exposes them reliably through AzAPI.
  - Preserve the current environment creation, diagnostics, private endpoint, default domain, and certificate upload behavior.
  - Preserve the current app-level custom domain feature in the container app module.
- Must not:
  - Introduce any new required input that breaks existing callers.
  - Replace or recreate the Container Apps environment when only route config data changes.
  - Manage DNS records, domain ownership verification, or managed certificate lifecycle as part of this change.
  - Automatically bind the same hostname both at the environment route level and at the container app level.
- Allowed changes: Add new optional inputs, validations, outputs, AzAPI resources, example configuration, and documentation. Split implementation into a new Terraform source file if that improves clarity. Leave existing public inputs and outputs unchanged unless adding new optional outputs.
- Expected result: A caller can optionally configure environment-level routing and route custom domains through the ACA environment module while all existing module consumers remain backward compatible.
- Explicit non-goals:
  - Replacing the existing app module custom domain feature.
  - Managing target container apps from the environment module.
  - Managing DNS zones, A records, TXT verification records, or automatic managed certificate provisioning.
  - Performing automatic migration from app-bound custom domains to route-bound custom domains.

## 5. Acceptance Criteria [Core]
- [x] When the new route configuration input is omitted or empty, existing module consumers produce no behavior change and no additional resources.
- [x] When route configuration input is provided, Terraform plans and applies the environment-level route config resource through AzAPI without replacing the Container Apps environment.
- [x] The module supports route matches for `path`, `prefix`, and `pathSeparatedPrefix` and maps them correctly to the ARM API.
- [x] The module supports route targets for `containerApp` and optional `label`, `revision`, and `weight`.
- [x] The module supports custom domain entries with `Disabled`, `Auto`, and `SniEnabled`, and enforces certificate requirements for `SniEnabled`.
- [x] Existing environment certificate output remains usable for route custom domains.
- [x] Module validation passes after the change.
- [x] `/Users/kennethag/projects/azure-module/examples/aca-simple` is used or extended as the validation harness when no end-to-end framework is available, and it demonstrates routing traffic to at least two container apps.
- [x] Documentation explains prerequisites, limitations, and the difference between environment-level routing domains and app-level custom domains if the repo has a standard place for that documentation, otherwise the change explicitly records why no doc update is required.
- [x] Existing example behavior remains correct unless explicitly extended for this feature.

### Implementation Notes (2026-04-15)

**Files changed:**
- `acaenv/variables.tf` — added optional `http_route_configs` (map, defaults `{}`). Six validation rules enforce: name regex `^[a-z][a-z0-9]*$` (3-63 chars); at least one rule per config; at least one route and target per rule; each route match sets at least one of `path`/`prefix`/`path_separated_prefix`; valid `binding_type` values; `SniEnabled` requires `certificate_id`; target `weight` is a whole number 0–100.
- `acaenv/locals.tf` — added `local.http_route_configs` normalising `binding_type` using the same rule as the existing `aca` module: `SniEnabled` when `certificate_id` is present, otherwise `Disabled`.
- `acaenv/http_route_configs.tf` *(new)* — `for_each` over normalised configs; creates `Microsoft.App/managedEnvironments/httpRouteConfigs@2024-10-02-preview` via `azapi_resource`; `schema_validation_enabled = false` and `ignore_null_property = true` for preview-API tolerance; exports `fqdn` via `response_export_values`.
- `acaenv/outputs.tf` — three additive outputs: `http_route_config_ids`, `http_route_config_names`, `http_route_config_fqdns`.
- `examples/aca-simple/aca.tf` — added `locals` block for stable app/route names; added `module "showcase_app"` (`mcr.microsoft.com/k8se/quickstart:latest`) as second routing target.
- `examples/aca-simple/acaenv.tf` — wired `http_route_configs` with one route config (`approuter`) demonstrating all three match types (`prefix`, `path`, `path_separated_prefix`) routed to two different apps.
- `examples/aca-simple/outputs.tf` — added `showcase_fqdn` and `route_config_fqdn`.
- `README.md` — added "ACA Environment Rule-Based Routing" section to the repo's only established documentation surface.

**Open questions resolved:**
- FQDN is exported via `response_export_values = { fqdn = "properties.fqdn" }` and exposed as `http_route_config_fqdns`. The field is confirmed present in the `2024-10-02-preview` response; `try(..., null)` guards against absent values from older or inconsistent API responses.
- Multiple route configs are supported from day one via the map input.

**Validation:**
- `just tf-validate acaenv` → `Success! The configuration is valid.`
- `just tf-validate examples/aca-simple` → `Success! The configuration is valid.`
- `just tf-fmt` → no formatting differences.

## 6. Inputs, Outputs, and Interfaces [Optional]
- Inputs:
  - A new optional route configuration input, recommended as a map keyed by route config resource name for stable `for_each` behavior.
- Outputs:
  - Route config IDs by name.
  - Route config names by name.
  - Route config FQDNs by name if the API surface exposes them cleanly through AzAPI.
- Configuration or data shape:
  - Recommended shape:
    ```hcl
    http_route_configs = map(object({
      custom_domains = optional(list(object({
        name           = string
        binding_type   = optional(string)
        certificate_id = optional(string)
      })), [])
      rules = list(object({
        description = optional(string)
        routes = list(object({
          match = object({
            path                  = optional(string)
            prefix                = optional(string)
            path_separated_prefix = optional(string)
            case_sensitive        = optional(bool)
          })
          action = optional(object({
            prefix_rewrite = optional(string)
          }))
        }))
        targets = list(object({
          container_app = string
          label         = optional(string)
          revision      = optional(string)
          weight        = optional(number)
        }))
      }))
    }))
    ```
- Variables or parameters:
  - Route config name.
  - Custom domain hostname.
  - Custom domain binding type.
  - Environment certificate ID.
  - Rule descriptions.
  - Match expressions.
  - Prefix rewrite values.
  - Target app names and optional revision-routing values.
- Defaults:
  - The feature should default to disabled by using an empty map or `null`.
  - `binding_type` should default in a way that does not surprise the caller. If no certificate is provided, do not silently force `SniEnabled`.
- Validation rules:
  - Route config names must satisfy Azure naming constraints for `httpRouteConfigs`.
  - `SniEnabled` requires a certificate ID.
  - Each route config must contain at least one rule.
  - Each rule must contain at least one route and at least one target.
  - Target weights, when provided, must be within Azure's allowed range.
  - Validation should catch obvious caller mistakes without over-constraining combinations that Azure supports.
- Stable identifiers or matching keys:
  - Route config map keys are the stable Terraform identifiers and should map directly to Azure child resource names.
- Source of truth or authority model:
  - Terraform input is the desired state for route configs.
  - Azure is the source of truth for computed runtime values such as FQDN.
  - Domain ownership verification and DNS are external to the module.
- Field mapping or interface contract rules:
  - `binding_type` maps to Azure `bindingType`.
  - `path_separated_prefix` maps to Azure `pathSeparatedPrefix`.
  - `prefix_rewrite` maps to Azure `prefixRewrite`.
  - `container_app` maps to Azure `containerApp`.
- Backward compatibility expectations:
  - Existing callers do not need to change anything.
  - Existing outputs stay intact.
  - New outputs are additive only.

## 7. Terraform and Infrastructure Details [Optional]
- Terraform version and provider constraints:
  - Reuse the current module constraints.
  - Continue using `azapi` because there is no native `azurerm` resource for this feature.
- Resources affected:
  - New AzAPI child resources for environment-level HTTP route configs.
- Modules affected:
  - ACA environment module directly.
  - Example configuration and possibly documentation that explains interaction with the ACA module.
- Variables added or changed:
  - Add one new optional route configuration input.
- Outputs added or changed:
  - Add route config outputs.
- Environment or workspace impact:
  - No required changes for existing callers.
  - New callers must satisfy DNS and certificate prerequisites when using custom domains.
- Plan and apply expectations:
  - Route config changes should result in child resource create, update, or delete behavior only.
  - Route config changes must not force recreation of the environment.
- State migration, import, replacement, or drift considerations:
  - No migration is required for existing users.
  - If route config keys are renamed, Terraform will treat that as resource replacement for the affected child resource only.
  - Preview API drift remains a risk and must be documented.
- Rollback expectations:
  - Removing route config input should remove only the route config child resources and must leave the environment intact.

## 8. Files and Components Touched [Optional]
- Main files or directories affected:
  - ACA environment module variable definitions.
  - ACA environment module resource definitions.
  - ACA environment module outputs.
  - Example configuration.
  - Module documentation.
- Existing example or validation harness to reuse:
  - `/Users/kennethag/projects/azure-module/examples/aca-simple`
- New files to create:
  - A dedicated Terraform source file for route config resources if that keeps the implementation clearer.
- Existing files to update:
  - The environment module implementation and outputs.
  - `/Users/kennethag/projects/azure-module/examples/aca-simple` to exercise the new route configuration when no E2E framework exists.
  - Any shared documentation or example readme content needed to explain usage.
- Areas that must not be changed:
  - Existing required inputs.
  - Existing environment behavior when the feature is disabled.
  - Existing app-level custom domain support in the ACA module.

## 9. Workflow or Processing Logic [Optional]
- Trigger or entry point:
  - The caller provides one or more route config definitions in the new optional module input.
- Main flow:
  1. Create or reuse the Container Apps environment with its existing behavior.
  2. Optionally create or reuse the environment certificate through the existing certificate support.
  3. For each configured route config, create an AzAPI child resource under the environment.
  4. Translate Terraform input fields into the Azure HTTP route config ARM schema.
  5. Expose child resource IDs and any supported computed outputs.
- Conditional behavior:
  - If no route configs are provided, do not create any route-related resources.
  - If `binding_type` is `SniEnabled`, require a valid environment certificate ID.
  - If `binding_type` is `Auto`, allow the route config without a certificate ID and document that HTTPS depends on managed certificate availability outside this module.
  - If a hostname is intended for environment-level route-based routing, do not also bind that hostname through the container app module.
- Side effects or follow-up actions:
  - A route config may expose an environment-level FQDN and optionally a custom domain.
  - DNS records and certificate readiness remain caller responsibilities outside the module.

## 10. External Dependencies [Optional]
- Dependency:
  - Azure ARM preview API `Microsoft.App/managedEnvironments/httpRouteConfigs@2024-10-02-preview`
- Purpose:
  - Provides the environment-level routing capability missing from `azurerm`.
- Authentication or credentials:
  - Standard Azure provider authentication used by Terraform.
- Required permissions:
  - Sufficient permissions to create and update resources in the resource group and managed environment.
- Failure behavior:
  - Terraform apply fails if the preview API rejects the payload or the caller lacks permissions.
- Rate limits, quotas, or operational limits:
  - Standard Azure ARM limits apply.

- Dependency:
  - AzAPI Terraform provider
- Purpose:
  - Terraform bridge for unsupported ARM resource types.
- Authentication or credentials:
  - Same Azure authentication context as the rest of the module.
- Required permissions:
  - Same as above.
- Failure behavior:
  - Plan or apply fails if the provider cannot serialize or apply the child resource correctly.

- Dependency:
  - External DNS and certificate prerequisites
- Purpose:
  - Required for route custom domains.
- Authentication or credentials:
  - Managed outside the module.
- Required permissions:
  - Managed outside the module.
- Failure behavior:
  - The route config may exist but custom domain traffic or HTTPS may not function until DNS and certificate prerequisites are satisfied.

## 11. Constraints and Risks [Optional]
- Compatibility constraints:
  - The enhancement must be additive and backward compatible.
  - The input model must not force new required values on existing callers.
- Security constraints:
  - Certificate IDs must reference certificates that already exist in the managed environment.
  - Sensitive certificate material handling must remain limited to the existing environment certificate feature.
- Performance or reliability expectations:
  - Route config updates should be isolated from the environment resource lifecycle.
- Operational limits:
  - This feature depends on a preview Azure API and may change over time.
- Known tradeoffs:
  - AzAPI is required because `azurerm` does not yet support the feature.
  - The module will support route config declaration, but not full domain lifecycle management.
  - Callers must choose either environment-level route domains or app-level domain binding per hostname.
- Explicitly forbidden changes:
  - Breaking existing consumers.
  - Auto-migrating existing app custom domain configuration.
  - Recreating the environment for route-only changes.
  - Hiding Azure preview limitations behind misleading abstractions.

## 12. Rollout, Migration, and Operations [Complex]
- Deployment order:
  - Introduce the new optional input and outputs.
  - Implement the AzAPI child resource.
  - Add validation and documentation.
  - Add a dedicated example and verify behavior in a non-production subscription.
- Environment promotion path:
  - Validate first in a dedicated example or sandbox environment before release.
- Data or state migration steps:
  - None for existing users.
  - New users opt in by setting the route config input.
- One-time setup or bootstrap needs:
  - Azure provider registration and preview API availability.
  - External DNS records for custom domains.
  - Environment certificate or managed certificate readiness when HTTPS is required.
- Recovery or rollback plan:
  - Remove or disable the route config input to destroy only route config child resources.
  - Preserve the environment and existing app module behavior.
- Monitoring after rollout:
  - Verify returned FQDN and path-based routing.
  - Verify custom domain resolution and HTTPS behavior where applicable.

## 13. Error Handling and Failure Cases [Complex]
- Fail if:
  - A route config name violates Azure naming requirements.
  - `SniEnabled` is configured without a certificate ID.
  - A route config contains no rules.
  - A rule contains no routes or no targets.
  - Azure rejects the resource because a referenced container app name, certificate ID, or hostname contract is invalid.
- Warn if:
  - `Auto` binding is used without a managed certificate already available, because HTTPS may not be active immediately.
  - The same hostname appears to be intended for both route-level and app-level binding.
- Retry strategy:
  - Rely on normal Terraform retry behavior for transient ARM failures; do not build custom retry logic into the module.
- Partial failure behavior:
  - Route config creation failures must fail the apply without recreating or replacing the Container Apps environment.
- Required operator action:
  - Fix DNS records, certificate prerequisites, invalid route configuration data, or Azure API contract issues before reapplying.

## 14. Actors and Ownership [Complex]
- Human actors:
  - Module maintainers who add the feature and preserve backward compatibility.
  - Module consumers who opt into route configuration, provide target app names, and manage DNS and certificate prerequisites.
- Automated actors:
  - Terraform.
  - AzAPI provider.
  - Azure Resource Manager.
- Systems involved:
  - The ACA environment module.
  - Azure Container Apps managed environment.
  - Azure ARM preview API for `httpRouteConfigs`.
  - External DNS and certificate infrastructure.
- System of record:
  - Terraform configuration is the source of truth for desired route config state.
  - Azure is the source of truth for computed resource state and runtime values returned by the API.
- Ownership rules for data, fields, or resources:
  - The module owns the translation from Terraform input into the AzAPI payload.
  - Callers own the selection of route names, hostnames, target apps, and any external DNS or certificate setup.
  - Azure owns validation of the preview resource contract and the resulting runtime behavior.
- Required operator or approver actions:
  - Provide valid DNS records for custom domains.
  - Ensure certificates exist when `SniEnabled` is used.
  - Validate the feature in a sandbox or example environment before wider rollout.

## 15. Implementation Plan and Milestones [Optional]
- Suggested order of work:
  1. Define the new optional route config input shape and validation strategy.
  2. Implement the AzAPI child resource and outputs in the ACA environment module.
  3. Reuse or extend `/Users/kennethag/projects/azure-module/examples/aca-simple` as the validation harness with at least two target container apps if no E2E framework exists.
  4. Validate backward compatibility and confirm the environment is not replaced on route-only changes.
- Validation checkpoints:
  - Module validation succeeds.
  - A sample route config plan shows only additive child resources.
  - A sample route configuration successfully routes two paths to two different container apps.
  - A custom domain example documents the external DNS and certificate prerequisites clearly.
- Future follow-up items:
  - Consider managed certificate lifecycle support only if there is a strong need and a stable Azure or Terraform path.
  - Consider additional outputs only if AzAPI exposes them consistently.

## 16. Open Questions [Optional]
- Should the first iteration expose route config FQDN outputs only when they are confirmed stable in the AzAPI response, or should it export the full response body for callers to consume?
- Should the first iteration support multiple route configs from day one, or should it intentionally start with a single route config to keep the input surface smaller?

## 17. Notes for the LLM [Core]
- Prefer the smallest additive change that satisfies the feature.
- Reuse the repository's current AzAPI implementation style instead of inventing a new abstraction.
- Keep the new route config input optional and backward compatible by default.
- Do not redesign the existing environment module, certificate flow, or container app custom domain behavior.
- Make the boundary between environment-level route custom domains and app-level custom domains explicit.
- Reflect the Azure ARM field names accurately when mapping Terraform input to AzAPI payload fields.
- If the target repo has no standard documentation surface for this feature, explicitly skip doc changes instead of inventing one.
- If no end-to-end framework exists, use `/Users/kennethag/projects/azure-module/examples/aca-simple` as the validation harness and carry that path explicitly in the implementation context.
- Keep DNS and managed certificate lifecycle out of scope unless the requirements are explicitly expanded.
- Avoid speculative support for unsupported Azure behaviors.