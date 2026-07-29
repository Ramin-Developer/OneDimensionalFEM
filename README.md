# One-Dimensional FEM (MATLAB)

MATLAB implementation of a one-dimensional boundary value problem solved with the finite element method (FEM).

## Repository Layout

- `src/matlab/`: Canonical MATLAB source files.
- `finite-element-method/matlab-code/`: Legacy compatibility wrappers.
- `finite-element-method/documentation/`: LaTeX sources and figure assets.
- `docs/reference/main.pdf`: Reference/problem documentation artifact.
- `tests/`: MATLAB test harness (R2017a-compatible).

## Quick Start

1. Open MATLAB.
2. Set the current folder to `src/matlab`.
3. Run `Main_Program.m`.

## Running Tests

1. Open MATLAB at repository root.
2. Run `results = runtests('tests');`.
3. Confirm all tests pass: `assert(all([results.Passed]));`.

## Notes

- This repository is being prepared for modernization and refactoring.
- Baseline behavior should be preserved while improving structure and testability.

## Plan and Progress

- Living modernization plan: [docs/MODERNIZATION_PLAN.md](docs/MODERNIZATION_PLAN.md)
- Active modernization branch: feat/refactor-core
