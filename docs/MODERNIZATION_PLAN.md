# Modernization Plan (Living Document)

This plan is the single source of truth for incremental updates across sessions.

## Scope

- Preserve numerical behavior of current 1D FEM implementation.
- Improve readability, modularity, and testability.
- Add reproducible checks in CI.

## Current Baseline

- Active branch: main (use short-lived feat/* branches per task)
- Existing CI: MATLAB tests in .github/workflows/matlab-ci.yml
- Canonical code location: src/matlab
- LaTeX documentation location: docs/latex

## Working Rules

- Keep changes small and reversible.
- One concern per commit.
- Add tests before or together with refactors when feasible.
- Keep a short session note in this file after each work block.

## Phase Plan

## Completed Milestones

- [x] Repository migrated and cleaned to a single active repo.
- [x] Canonical MATLAB code moved to src/matlab.
- [x] Legacy MATLAB wrapper path removed to avoid ambiguity.
- [x] Documentation tree normalized to docs/latex and docs/reference.
- [x] Baseline validation added in src/matlab/Validate_Input.m.
- [x] Initial test suite added under tests/.
- [x] CI executes MATLAB tests.
- [x] Baseline benchmark scaffold added at scripts/benchmark_solver.m.

## Workstream Plan (Competency-Driven)

### Workstream A: Code Analysis and Refactor

- [x] A1: Extract a pure compute API that returns solution/error data without plotting side effects.
- [x] A2: Isolate plotting from Show_Results into dedicated plotting utility.
- [x] A3: Standardize function signatures and naming across src/matlab.
- [x] A4: Add lightweight inline function-level contracts (inputs/outputs assumptions).

Definition of Done:

- Numerical outputs unchanged for baseline scenarios.
- Main_Program remains a thin orchestration script.

### Workstream B: Unit and Regression Testing

- [x] B1: Shape-function sanity checks.
- [x] B2: Element-assembly consistency checks.
- [x] B3: End-to-end refinement regression checks.
- [x] B4: Add deterministic golden-data regression snapshots (values and tolerances).
- [x] B5: Add negative tests for invalid inputs to Validate_Input.

Definition of Done:

- run_all_tests passes locally and in CI.
- Failures provide actionable messages.

### Workstream C: Numerical Validation

- [x] C1: Add reference-case JSON/ MAT snapshots for selected N values.
- [x] C2: Add convergence-rate checks with explicit thresholds.
- [x] C3: Add boundary-condition residual checks as formal assertions.

Definition of Done:

- Regression tests detect unintended numerical drift.

### Workstream D: Performance and Vectorization

- [x] D1: Baseline benchmark script available.
- [x] D2: Add repeat-count and summary statistics (min/median/max) to benchmark.
- [x] D3: Profile hot paths and document optimization opportunities.
- [x] D4: Add optional performance guardrails (informational thresholds) in CI/nightly.

Definition of Done:

- Benchmark output is reproducible and version-comparable.

### Workstream E: Documentation and Release Hygiene

- [ ] E1: Update README with canonical run/test/benchmark commands only.
- [ ] E2: Add CONTRIBUTING notes for branch/PR workflow and R2017a constraints.
- [ ] E3: Keep modernization plan status current per merged PR.

Definition of Done:

- New contributors can run, test, and benchmark without ambiguity.

## Branching Strategy

- main: stable branch
- short-lived branches for focused tasks, merged into main via PR

Recommended branch naming:

- feat/refactor-*
- test/*
- perf/*
- docs/*

## Session Update Template

Append a short note at the top of the log below after each session:

- Date:
- Branch:
- What changed:
- Tests run:
- Next action:

## Session Log

- Date: 2026-07-27
- Branch: feat/refactor-core
- What changed: Repository moved to new GitHub account, branch renamed to main, feature branch created, Main_Program change preserved and pushed, initial MATLAB CI workflow added.
- Tests run: CI smoke workflow file added (not yet executed locally in MATLAB).
- Next action: create matlab.unittest baseline tests and wire CI to run them.

- Date: 2026-07-29
- Branch: perf/benchmark-d2-followup-20260729
- What changed: Updated benchmark_solver to support configurable repeat counts and report min/median/max elapsed seconds per mesh size.
- Tests run: MATLAB test suite executed via -nodesktop/-r flow (R2017a-compatible), exit code 0.
- Next action: implement Workstream D3 profiling of hot paths and summarize optimization opportunities.

- Date: 2026-07-29
- Branch: main (after PR merges)
- What changed: Canonical src/matlab layout finalized, docs moved to docs/latex, wrapper path removed, regression tests and benchmark scaffold added, CI test execution confirmed.
- Tests run: MATLAB test suite executed locally and in CI workflow.
- Next action: implement Workstream A and B4/B5 (pure compute API and deterministic golden-data checks).

- Date: 2026-07-29
- Branch: chore/modernization-followup-20260729
- What changed: Added Compute_FEM_Data as a compute-only API, updated Main_Program to orchestrate compute then plotting, and added tests validating no plotting side effects in compute flow.
- Tests run: Not executed locally in this session (MATLAB runner not invoked from terminal).
- Next action: implement Workstream A2 by splitting plotting out of Show_Results into a dedicated plotting utility.

- Date: 2026-07-29
- Branch: chore/modernization-followup-20260729
- What changed: Extracted plotting from Show_Results into Plot_FEM_Solutions and kept Show_Results focused on orchestration and error estimation.
- Tests run: MATLAB suite executed via batch runner (exit code 0).
- Next action: implement Workstream A3 by standardizing signatures and naming across src/matlab.

- Date: 2026-07-29
- Branch: chore/modernization-followup-20260729
- What changed: Standardized naming/signatures across core src/matlab pipeline (Def_Problem, Calc_FEM_Sol, Solve_Eq_Sys, Show_Results, Plot_FEM_Solutions, Compute_FEM_Data, Main_Program, Read_input) without behavior changes.
- Tests run: MATLAB suite executed via batch runner (exit code 0).
- Next action: implement Workstream A4 by adding lightweight function-level contracts.

- Date: 2026-07-29
- Branch: chore/modernization-followup-20260729
- What changed: Added lightweight inline contracts (assert-based input/output assumptions) across core compute, assembly, and result functions.
- Tests run: MATLAB suite executed via batch runner (exit code 0).
- Next action: start Workstream B4 deterministic golden-data regression snapshots.

- Date: 2026-07-29
- Branch: chore/modernization-followup-20260729
- What changed: Added deterministic golden snapshot regression baseline in tests/golden/baseline_qconst_snapshot.mat and test_golden_snapshot_regression.m with explicit tolerances for exact/FEM fields, squared errors, and convergence factors.
- Tests run: MATLAB test suite executed via -nodesktop/-r flow (R2017a-compatible), exit code 0.
- Next action: implement Workstream B5 negative-input tests for Validate_Input.

- Date: 2026-07-29
- Branch: chore/modernization-followup-20260729
- What changed: Added Validate_Input negative tests for invalid q_Type, unsupported q_Type, invalid coefficients, invalid boundary values, and invalid element vectors.
- Tests run: MATLAB test suite executed via -nodesktop/-r flow (R2017a-compatible), exit code 0.
- Next action: begin Workstream C1 reference-case snapshot expansion for selected N values.

- Date: 2026-07-29
- Branch: chore/modernization-followup-20260729
- What changed: Added per-mesh reference-case MAT snapshots for selected N values and test coverage that validates exact/FEM field and error values against those snapshots.
- Tests run: MATLAB test suite executed via -nodesktop/-r flow (R2017a-compatible), exit code 0.
- Next action: implement Workstream C2 convergence-rate checks with explicit thresholds.

- Date: 2026-07-29
- Branch: test/convergence-thresholds-20260729
- What changed: Added explicit convergence-rate threshold assertions for linear and cubic FEM factors using baseline-derived margins.
- Tests run: MATLAB test suite executed via -nodesktop/-r flow (R2017a-compatible), exit code 0.
- Next action: implement Workstream C3 boundary-condition residual assertions.

- Date: 2026-07-29
- Branch: test/boundary-residual-checks-20260729
- What changed: Added formal right-boundary residual assertions for linear and cubic FEM, including linear refinement trend checks and explicit tolerances.
- Tests run: MATLAB test suite executed via -nodesktop/-r flow (R2017a-compatible), exit code 0.
- Next action: continue Workstream D2 benchmark repeat-count and summary statistics.

- Date: 2026-07-29
- Branch: perf/profile-hotpaths-d3-20260729
- What changed: Added `scripts/profile_solver_hotpaths.m`, generated profiling artifact `docs/performance_hotspots.txt`, and documented measured hotspots plus prioritized optimization opportunities in `docs/PERFORMANCE_PROFILE_D3.md`.
- Tests run: MATLAB test suite executed via -nodesktop/-r flow (R2017a-compatible), exit code 0.
- Next action: implement Workstream D4 optional CI/nightly performance guardrails.

- Date: 2026-07-29
- Branch: perf/d4-ci-guardrails-20260729
- What changed: Added `scripts/ci_performance_guardrail.m` and updated `.github/workflows/matlab-ci.yml` with nightly/manual informational performance guardrail job and event gating for test vs. nightly jobs.
- Tests run: Local guardrail run via -nodesktop/-r flow (R2017a-compatible), exit code 0.
- Next action: begin Workstream E1 README command refresh.
