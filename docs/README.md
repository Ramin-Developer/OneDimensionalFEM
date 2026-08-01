# OneDimensionalFEM

This repository contains a MATLAB implementation of a one-dimensional finite element method (FEM) solver together with LaTeX-based documentation.

## Project purpose

The code focuses on solving a simple 1D boundary value problem with FEM, while the documentation in the `docs/latex` tree captures the mathematical formulation, implementation notes, and results.

## Documentation map

- [REFACTOR_PLAN.md](REFACTOR_PLAN.md) - ranked corrective roadmap.
- [MODERNIZATION_PLAN.md](MODERNIZATION_PLAN.md) - living status summary.
- [MODERNIZATION_BACKLOG.md](MODERNIZATION_BACKLOG.md) - next modernization tasks.
- [ARCHITECTURE_MAP.md](ARCHITECTURE_MAP.md) - ownership boundaries and runtime flow.
- [MODULE_CONTRACTS.md](MODULE_CONTRACTS.md) - public entry-point contracts and ownership boundaries.
- [NUMERICAL_VERIFICATION.md](NUMERICAL_VERIFICATION.md) - numerical evidence references.
- [PERFORMANCE_GUARDRAIL.md](PERFORMANCE_GUARDRAIL.md) - baseline and threshold policy.
- [PERFORMANCE_PROFILE_D3.md](PERFORMANCE_PROFILE_D3.md) - hotspot findings and reproduction.
- [PERFORMANCE_QUADRATURE.md](PERFORMANCE_QUADRATURE.md) - quadrature optimization evidence.
- [PERFORMANCE_SPARSE_ASSEMBLY.md](PERFORMANCE_SPARSE_ASSEMBLY.md) - sparse assembly evidence.
- [latex/](latex/) - report source tree.
- [reference/](reference/) - generated reference artifacts.

## Source map

- `src/matlab/` - production solver code.
- `tests/` - regression and oracle tests.
- `scripts/` - benchmark/profile/report tooling.

## Modernization focus

The current modernization work emphasizes:

- clearer and more consistent naming
- reduced duplication and simpler structure
- better documentation and maintainability
- more readable MATLAB and LaTeX organization

## Project backlog

A lightweight backlog of future follow-up ideas is maintained in [TODO.md](TODO.md).
