# One-Dimensional FEM

MATLAB implementation of a one-dimensional finite element method (FEM) solver with reproducible tests, benchmarks, and report build tooling.

## Current Setup

Repository layout:

- `src/matlab/`: MATLAB solver and supporting numerical routines.
- `tests/`: MATLAB test harness and regression coverage.
- `scripts/`: benchmark, CI guardrail, and report-build helpers.
- `docs/latex/`: LaTeX source and figure assets.
- `docs/reference/`: generated reference artifacts.

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

Run the informational performance guardrail:

```matlab
addpath('scripts');
ci_performance_guardrail
```

Run profiling with path-normalized output to `%TEMP%`:

```powershell
.\scripts\run_profile_hotpaths.ps1
```

The versioned baseline and threshold policy are documented in [docs/PERFORMANCE_GUARDRAIL.md](docs/PERFORMANCE_GUARDRAIL.md).

## Building the Report

Build the PDF, nomenclature, and terminology glossary:

```powershell
.\scripts\build_report.ps1
```

## Project Plans

- Corrective roadmap: [docs/REFACTOR_PLAN.md](docs/REFACTOR_PLAN.md)
- Living status: [docs/MODERNIZATION_PLAN.md](docs/MODERNIZATION_PLAN.md)
- Modernization backlog: [docs/MODERNIZATION_BACKLOG.md](docs/MODERNIZATION_BACKLOG.md)
- Architecture map: [docs/ARCHITECTURE_MAP.md](docs/ARCHITECTURE_MAP.md)
- Module contracts: [docs/MODULE_CONTRACTS.md](docs/MODULE_CONTRACTS.md)
