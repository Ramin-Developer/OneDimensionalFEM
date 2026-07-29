# Modernization Plan (Living Document)

This plan is the single source of truth for incremental updates across sessions.

## Scope

- Preserve numerical behavior of current 1D FEM implementation.
- Improve readability, modularity, and testability.
- Add reproducible checks in CI.

## Current Baseline

- Active feature branch: feat/matlab-phase2-tests-refactor
- Existing CI: MATLAB smoke check in .github/workflows/matlab-ci.yml
- Canonical code location: src/matlab
- LaTeX documentation location: docs/latex

## Working Rules

- Keep changes small and reversible.
- One concern per commit.
- Add tests before or together with refactors when feasible.
- Keep a short session note in this file after each work block.

## Phase Plan

## Phase 0: Baseline Safety (Done/Ready)

- [x] Move repository to new GitHub remote.
- [x] Add repository README and .gitignore.
- [x] Add initial MATLAB CI smoke check.
- [ ] Add deterministic sample inputs and expected outputs snapshot.

## Phase 1: Test Harness

- [ ] Add tests folder: tests
- [ ] Add matlab.unittest runner script.
- [ ] Add at least 3 baseline tests:
  - [ ] Shape function sanity test
  - [ ] Element assembly consistency test
  - [ ] End-to-end solution regression test
- [ ] Update CI to run the test suite.

Status update (2026-07-29):

- Added tests/run_all_tests.m
- Added tests/test_shape_functions.m
- Added tests/test_element_assembly.m
- Added tests/test_end_to_end_regression.m
- CI workflow executes tests from tests/

## Phase 2: Structural Refactor

- [x] Introduce src folder and move core computational functions.
- [x] Remove compatibility wrappers to avoid source-of-truth ambiguity.
- [ ] Separate I/O and plotting from numerical core.
- [ ] Standardize function signatures and naming.

## Phase 3: Reliability and UX

- [ ] Add input validation and clear error messages.
- [ ] Add reproducible example scripts.
- [ ] Add result export conventions.
- [ ] Add minimal performance benchmark script.

Status update (2026-07-29):

- Added scripts/benchmark_solver.m for baseline runtime tracking.

## Branching Strategy

- main: stable branch
- short-lived branches for focused tasks, merged into main via PR

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
