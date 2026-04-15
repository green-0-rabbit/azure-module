---
name: implement-spec
description: "Implement code, configuration, documentation, and validation work directly from a spec file, usually under .specs/. Use when the user asks to implement a spec, execute a spec, work from acceptance criteria, or turn a written specification into real changes and validation."
argument-hint: "Provide the spec path or describe the spec to implement"
user-invocable: true
---

# Implement Spec

Implement changes directly from a specification and drive the work to completed, validated code rather than stopping at analysis.

Use [the workspace template](https://github.com/green-0-rabbit/foundation/blob/main/template.spec.md) to understand section meanings.
Use [the execution checklist](./references/execution-checklist.md) to translate the spec into concrete implementation steps.
Use [the create-spec profile guide](https://github.com/green-0-rabbit/foundation/blob/main/create-spec/references/profile-selection.md) to understand how small, feature, and complex specs differ.

## When to Use

- The user asks to implement a spec file under `.specs/`.
- The user asks to execute a specification, acceptance criteria, or implementation plan.
- The user wants code or configuration changes that follow an existing spec instead of writing a new one.
- The task is spec-driven and should be completed end to end, including validation.

## Procedure

1. Read the target spec completely before editing code.
2. Extract the following from the spec:
   - target repo or module
   - deliverables
   - explicit requirements and non-goals
   - constraints and risks
   - acceptance criteria
   - validation harness, tests, or example path
3. Inspect only the code and files needed to satisfy the spec.
4. Reuse existing repository patterns, naming, and validation commands.
5. Implement the smallest set of changes that satisfies the spec.
6. Update documentation only when the spec requires it and the target repo has an established documentation surface.
7. Validate using the repo's automated checks when available.
8. If no end-to-end framework exists, use the example folder or runnable config or code path named in the spec as the validation harness.
9. Compare the finished work back to the acceptance criteria and identify any remaining gaps.
10. Report what was implemented, how it was validated, and any unresolved blockers.

## Quality Bar

- Do not stop at planning when implementation is possible.
- Treat the spec as the contract; do not silently expand scope.
- Respect explicit non-goals and forbidden changes.
- Keep changes minimal, additive, and consistent with the target codebase.
- Validation must map back to the spec's named checks or harness.
- If the spec is missing a crucial detail, make the safest narrow assumption and state it explicitly.

## Output Rules

- Prefer implementing the spec directly instead of restating it.
- Use the spec's acceptance criteria as the completion checklist.
- If the spec names a validation harness, include it in the execution and final summary.
- If part of the spec cannot be completed, say exactly which requirement remains and why.
