# One-Dimensional FEM

MATLAB-based implementation of a one-dimensional finite element method (FEM) solver, together with LaTeX documentation for the accompanying mathematical write-up and figures.

## Project Profile

This repository is a mixed software/documentation project:

- `src/matlab/`: MATLAB solver and supporting numerical routines.
- `docs/latex/`: LaTeX source, bibliography, and figure assets for the documentation.
- `docs/reference/`: compiled reference/documentation artifacts.
- `tests/`: MATLAB test harness and regression coverage.

## Quick Start

Run the main program:

```matlab
cd('src/matlab');
Main_Program
```

## Running Tests

Run the test suite:

```matlab
addpath('tests');
run_all_tests
```

Run tests with coverage:

```matlab
run('tests/run_tests_with_coverage.m')
```

## Test Coverage

Coverage is published automatically by CI in the job summary and coverage artifact.
Use the CI coverage summary to see the latest file-by-file view.

## Benchmarking

Run the benchmark:

```matlab
addpath('scripts');
benchmark_solver
```

## Notes

- This repository is being prepared for modernization and refactoring.
- Baseline behavior should be preserved while improving structure and testability.

## Plan and Progress

- Living modernization plan: [docs/MODERNIZATION_PLAN.md](docs/MODERNIZATION_PLAN.md)
- Active development branch: use short-lived `feat/*` branches from `main`
