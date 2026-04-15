# Spec Execution Checklist

Use this checklist before you mark a spec implementation as complete.

## Read the Contract

- Read the full spec, not just the summary.
- Capture the target paths, modules, or systems involved.
- Identify explicit non-goals and forbidden changes.

## Map Spec to Work

- Deliverables -> files or resources to change
- Functional requirements -> expected behavior to implement
- Acceptance criteria -> validation checklist
- Validation harness -> commands, tests, examples, or runnable paths

## Implement Safely

- Reuse established repository patterns.
- Keep behavior additive when backward compatibility is required.
- Avoid unrelated refactors.
- Make assumptions explicit when the spec leaves something open.

## Validate

- Run the existing test or validation commands when available.
- If no E2E framework exists, use the example folder or runnable config or code path named by the spec.
- Check the final changes against the acceptance criteria one by one.

## Final Check

- All required deliverables are implemented.
- Validation evidence exists for the changed behavior.
- Documentation updates match the spec's rules.
- Remaining gaps, if any, are explicit.
