---
name: implement-terraform-spec
description: "Implement Terraform and module specs directly from a spec file, including variables, resources, outputs, examples, and validation harnesses. Use for Terraform module enhancements, provider gaps, azurerm or azapi changes, example-driven validation, and backward-compatible infrastructure features."
argument-hint: "Provide the Terraform spec path or describe the spec to implement"
user-invocable: true
---

# Implement Terraform Spec

Implement Terraform module or configuration changes directly from a spec, with emphasis on backward compatibility, provider correctness, and practical validation.

Use [the generic implementation skill checklist](../implement-spec/references/execution-checklist.md) for the baseline workflow.
Use [the Terraform implementation checklist](./references/terraform-implementation-checklist.md) for module-specific concerns.
Use [the workspace template](https://github.com/green-0-rabbit/foundation/blob/main/template.spec.md) to interpret spec sections consistently.

## When to Use

- The spec targets Terraform modules, examples, providers, or deployment configuration.
- The user asks to implement a Terraform module enhancement from a spec.
- The work involves `azurerm`, `azapi`, state-safe resource changes, or example-based validation.
- The spec names an example folder as the validation harness.

## Procedure

1. Read the full spec and extract Terraform-specific deliverables:
   - variables and validations
   - resources and provider/API constraints
   - outputs
   - examples or validation harnesses
   - backward compatibility and rollout expectations
2. Inspect the target module's existing structure, patterns, and validation commands.
3. Prefer additive inputs and outputs unless the spec explicitly allows breaking changes.
4. Reuse existing provider patterns, including AzAPI usage, naming, and file organization.
5. Implement resource changes so that route-only or config-only updates do not trigger unnecessary replacement unless the spec explicitly allows it.
6. Update examples or runnable configurations named by the spec when they are the validation surface.
7. Run formatting and validation commands appropriate to the target repo.
8. If the spec relies on an example harness instead of an E2E framework, validate through that example path and report what was exercised.
9. Check the final result against the spec's acceptance criteria and rollback expectations.

## Quality Bar

- Inputs and outputs should remain backward compatible by default.
- Variable validation should catch obvious misconfiguration without blocking supported provider behavior.
- Provider and API versions must align with the spec.
- AzAPI should be used only where the spec or provider gap requires it.
- Example harness changes should be minimal but sufficient to validate the new feature.
- Do not invent DNS, certificate, or runtime automation beyond the explicit spec.

## Output Rules

- Implement the Terraform changes directly instead of only describing them.
- Report which module files, examples, and validation commands were used.
- Call out state or replacement risks when relevant to the spec.
- If example-based validation was used, name the exact example path.
