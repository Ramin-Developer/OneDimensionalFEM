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

No pending items remain in the ranked roadmap. New unscheduled maintenance ideas belong in [TODO.md](TODO.md).

## Session Log

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
