# Terraform Spec Implementation Checklist

Use this checklist when implementing Terraform specs.

## Inputs and Schema

- New variables are optional unless the spec explicitly requires otherwise.
- Object shapes, defaults, and validations match the spec.
- Backward compatibility expectations are preserved.

## Resources

- Resource types and API versions match the spec.
- Provider gaps are handled with the expected provider, such as AzAPI.
- Changes avoid unnecessary replacement when the spec requires additive behavior.

## Outputs

- New outputs are additive by default.
- Output names and shapes follow existing module conventions.

## Validation

- Reuse the repo's Terraform commands or wrappers if they exist.
- If no E2E framework exists, use the example folder or runnable config named by the spec.
- Ensure the example exercises the new behavior rather than only compiling.

## Safety

- Explicitly respect non-goals around DNS, certificates, migrations, or destructive changes.
- Surface preview API or provider risks when they are part of the implementation.
- Confirm the final work satisfies the spec's acceptance criteria and rollback expectations.
