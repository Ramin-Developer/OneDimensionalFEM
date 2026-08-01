# Modernization Wave 2 (Post MZ1-MZ5)

This plan defines the next ranked modernization wave after completing MZ1-MZ5.

## Wave 2 Goals

- Increase confidence in API-level compatibility for compute consumers.
- Improve CI signal quality for MATLAB regressions and modernization checks.
- Simplify contributor workflows without changing solver mathematics.

## Ranked Tasks

### MZ6. Add compute API golden-contract snapshots

[x] Scope:
- Add snapshot-based contract fixtures for key `Compute_FEM_Data` fields and dimensions.
- Verify compatibility of schema plus representative value shapes for baseline scenarios.

Status:
- Complete. Added `tests/golden/compute_api_contract_snapshot.json` and `tests/test_compute_api_contract_snapshot.m` to enforce contract field ordering plus baseline shape expectations.

Acceptance criteria:
- Contract snapshots detect unintentional output drift.
- Schema test and snapshot test fail independently with actionable messages.

### MZ7. Add focused CI matrix for modernization checks

[x] Scope:
- Separate docs-quality, API-contract, and smoke-test concerns into explicit CI jobs.
- Ensure each check reports a clear failure source.

Status:
- Complete. CI now runs distinct `docs-quality`, `smoke-test`, and `api-contract` jobs so failures map directly to documentation drift, smoke runtime checks, or compute API contract checks.

Acceptance criteria:
- CI failures point directly to docs drift, API drift, or runtime drift.
- Pull request checks remain fast enough for routine iteration.

### MZ8. Consolidate MATLAB run entrypoints

Scope:
- Provide one stable script entrypoint per workflow: smoke, regression, benchmark, profile.
- Remove overlapping command variants where possible.

Acceptance criteria:
- Contributors can run all workflows from repository root with one command each.
- README command set remains concise and non-duplicative.

### MZ9. Baseline runtime evidence refresh policy

Scope:
- Document when and how to refresh performance baselines after intended behavior-preserving refactors.
- Add checklist criteria for accepting baseline refresh PRs.

Acceptance criteria:
- Baseline updates are reproducible and auditable.
- Guardrail noise from accidental baseline churn is minimized.

## Suggested Execution Order

1. MZ8 (workflow ergonomics)
2. MZ9 (baseline governance)
