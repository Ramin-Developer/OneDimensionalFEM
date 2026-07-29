# One-Dimensional FEM (MATLAB)

MATLAB implementation of a one-dimensional boundary value problem solved with the finite element method (FEM).

## Repository Layout

- `src/matlab/`: Canonical MATLAB source files.
- `docs/latex/`: LaTeX sources and figure assets.
- `docs/reference/main.pdf`: Reference/problem documentation artifact.
- `tests/`: MATLAB test harness (R2017a-compatible).

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

Latest CI coverage report:

- overall line coverage: 51.41%
- critical files (<60%): Basis_Shape_Func.m, Export_Figure.m, Main_Program.m, Plot_FEM_Solutions.m, Read_input.m, Show_Results.m, Def_Problem.m
- low coverage files (60%-<80%): none

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
