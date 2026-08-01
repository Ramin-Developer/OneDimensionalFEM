# Modernization Plan (Living Document)

This plan tracks current modernization status and next work.

## Scope

- Preserve numerical behavior of current 1D FEM implementation.
- Improve readability, modularity, and testability.
- Add reproducible checks in CI.

## Current Baseline

- Active branch: main (use short-lived task branches per task)
- Existing CI: MATLAB tests in .github/workflows/matlab-ci.yml
- Canonical code location: src/matlab
- LaTeX documentation location: docs/latex

## Ranked Corrective Plan

The ranked corrective roadmap is maintained in [REFACTOR_PLAN.md](REFACTOR_PLAN.md). Its order is authoritative:

1. Mathematical correctness.
2. Independent verification.
3. Performance.
4. Report quality.
5. Maintainability.

## Status Summary

- M1-M3: complete.
- V1-V2: complete.
- P1-P3: complete.
- R1-R3: complete.
- C1-C2: complete.

## Completed Milestones

- [x] Repository migrated and cleaned to a single active repo.
- [x] Canonical MATLAB code moved to src/matlab.
- [x] Legacy MATLAB wrapper path removed to avoid ambiguity.
- [x] Documentation tree normalized to docs/latex and docs/reference.
- [x] Baseline validation added in src/matlab/Validate_Input.m.
- [x] Initial test suite added under tests/.
- [x] CI executes MATLAB tests.
- [x] Baseline benchmark scaffold added at scripts/benchmark_solver.m.
- [x] Ranked corrective roadmap executed through C2.

## Next Action

Execute MZ8 from [MODERNIZATION_WAVE2.md](MODERNIZATION_WAVE2.md): consolidate MATLAB run entrypoints.

## Session Log

- Date: 2026-08-01
- Branch: modernize/mz7-ci-matrix-20260801
- What changed: Completed MZ7 by splitting CI into explicit docs-quality, smoke-test, and api-contract jobs for clearer failure attribution.
- Tests run: `pwsh ./scripts/check_docs_quality.ps1` passed locally. CI workflow structure validated by YAML diff.
- Next action: execute MZ8 workflow entrypoint consolidation.

- Date: 2026-08-01
- Branch: modernize/mz6-contract-snapshots-20260801
- What changed: Completed MZ6 by adding a Compute API contract snapshot fixture and dedicated snapshot regression test.
- Tests run: `pwsh ./scripts/check_docs_quality.ps1` passed locally. MATLAB full suite not run in this terminal session.
- Next action: execute MZ7 CI matrix focus for modernization checks.

- Date: 2026-08-01
- Branch: modernize/wave2-backlog-20260801
- What changed: Defined and ranked the next modernization wave (MZ6-MZ9) and wired it into canonical docs navigation.
- Tests run: `pwsh ./scripts/check_docs_quality.ps1` passed locally.
- Next action: execute MZ6 compute API contract snapshots.

- Date: 2026-08-01
- Branch: modernize/mz5-compute-api-schema-20260801
- What changed: Completed MZ5 by formalizing a stable `Compute_FEM_Data` schema contract and adding dedicated schema regression coverage.
- Tests run: `pwsh ./scripts/check_docs_quality.ps1` passed locally. MATLAB suite not run in this terminal session.
- Next action: define and prioritize the next modernization wave beyond MZ1-MZ5.

- Date: 2026-08-01
- Branch: modernize/mz4-doc-quality-checks-20260801
- What changed: Completed MZ4 by adding automated documentation quality checks and wiring them into CI for push and pull request validation.
- Tests run: `pwsh ./scripts/check_docs_quality.ps1` passed locally.
- Next action: execute MZ5 stable compute API surface documentation and schema formalization.

- Date: 2026-08-01
- Branch: modernize/mz3-doc-architecture-20260801
- What changed: Completed MZ3 by making top-level README operational-only, consolidating canonical documentation navigation in docs/README, and synchronizing plan/backlog status references.
- Tests run: Not run; documentation-only modernization step.
- Next action: execute MZ4 modernization quality checks.

- Date: 2026-08-01
- Branch: modernize/mz2-path-normalization-20260801
- What changed: Completed MZ2 by removing the remaining hard-coded repository path in profiling docs and adding a repository-root profiling wrapper that writes outputs to temp.
- Tests run: Not run; tooling/docs-only modernization step.
- Next action: execute MZ3 documentation architecture strengthening.

- Date: 2026-08-01
- Branch: modernize/mz1-module-contracts-20260801
- What changed: Completed MZ1 by adding a public entry-point contract catalog and quick dependency map, and synchronized docs navigation/backlog items.
- Tests run: Not run; documentation-only modernization step.
- Next action: execute MZ2 path normalization in automation commands.

- Date: 2026-08-01
- Branch: task/next-20260801
- What changed: Completed C2 documentation cleanup by reducing stale historical claims in tracked planning docs, synchronizing roadmap status, and removing tracked generated profiler output.
- Tests run: Not run; documentation-only cleanup.
- Next action: none in ranked roadmap.
