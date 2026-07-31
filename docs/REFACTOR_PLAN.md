# Correctness and Refactoring Plan

This living plan is the source of truth for corrective MATLAB and report work. Tasks are ordered by expected value: correctness and trustworthy evidence precede performance and presentation.

## Working Rules

- Use one short-lived branch and pull request per numbered task unless tightly coupled changes require one atomic PR.
- Preserve MATLAB R2017a compatibility.
- Add an independent failing test before correcting numerical behavior.
- Regenerate affected golden data only after the corrected behavior is independently verified.
- Update this plan in every implementation PR. Update the README, report, tests, benchmarks, and modernization plan whenever their claims or commands change.

## Priority 1: Mathematical Correctness

### M1. Correct the error norm

- [x] Multiply each reference-element squared-error integral by the physical Jacobian $h$.
- [x] Consolidate duplicated error integration in `Compute_Error_Summary.m` and `Compute_FEM_Data.m`.
- [x] Add canonical `l2_Error_*` outputs and remove misleading `sq_Error_*` aliases.
- [x] Add an independent analytic norm test and correct duplicated test integration.
- [x] Regenerate affected snapshots and report tables, then validate the complete suite.

**Status:** Complete. Error magnitudes, snapshots, report tables, and terminology now use the physical $L^2$ norm.

### M2. Correct and verify boundary treatment

- [x] Fix the weak form so the natural boundary contribution is $P w(1)$.
- [x] Independently verify linear and cubic weak boundary rows.
- [x] Remove the additional cubic endpoint derivative constraint.
- [x] Add manufactured-solution tests for constant and variable coefficients.

**Status:** Complete. Both basis orders now impose the right natural condition through the weak boundary functional only.

### M3. Harden coefficient admissibility

- [x] Define valid coefficient counts and domains for every `q_Type`.
- [x] Reject zero exponential parameters, singular rational denominators, non-finite values, and invalid aliases consistently.
- [x] Add positive and negative tests for every supported model.

**Status:** Complete. All public construction paths share canonical aliases and enforce finite, strictly positive rigidity on $[0,1]$.

## Priority 2: Trustworthy Verification

### V1. Build an independent numerical oracle

- [x] Test element matrices and loads against closed-form cases rather than production helpers.
- [x] Cover all coefficient families, both basis orders, multiple meshes, and nonzero boundary data.
- [x] Separate compatibility snapshots from correctness assertions.

**Status:** Complete. Closed-form constant-element results and an independent fixed Gauss oracle now verify assembly and manufactured solutions.

### V2. Align outputs and terminology

- [x] Use consistent names for squared integrals, norms, reduction factors, and observed orders.
- [x] Ensure console labels, APIs, tests, plots, tables, and report equations describe the same quantities.
- [x] Record tolerances and their numerical justification.

**Status:** Complete. Public outputs now distinguish $L^2$ norms, error reduction factors, and mesh-ratio-aware observed orders.

## Priority 3: Performance

### P1. Use sparse assembly

- [x] Replace dense global matrices with sparse triplet assembly.
- [x] Benchmark memory and solve time over representative mesh sizes.

**Status:** Complete. Sparse storage scales linearly and used 2.6% of equivalent dense storage at $N=256$ without a runtime regression.

### P2. Reduce quadrature cost

- [x] Replace repeated adaptive element integrations with validated fixed-order Gauss quadrature where accuracy permits.
- [x] Reuse mapped coordinates, coefficient/load evaluations, and basis values across all element entries.
- [x] Fall back to adaptive quadrature when 16- and 32-point Gauss results do not agree at the requested tolerance.

**Status:** Complete. Representative median solve times improved by 92--95% while all numerical oracles and regression tests remained unchanged.

### P3. Establish performance gates

- [x] Capture a corrected, warmed baseline after sparse assembly and shared quadrature.
- [x] Report median runtime, baseline ratio, and memory scaling with informational CI thresholds.

**Status:** Complete. Versioned runtime and deterministic memory baselines now drive scheduled/manual informational checks without failing CI.

## Priority 4: Report Quality

### R1. Correct mathematical statements

- [x] Fix the weak formulation, bilinearity identity, continuity estimate, interpolation inequalities, and convergence notation.
- [x] Correct natural-flux interpretation, constrained-space uniqueness, function-space definitions, and analytical formulas.
- [x] Reconcile numerical tables with corrected code output and identify roundoff-only results explicitly.

**Status:** Complete. The mathematical derivations and claims now agree with the implemented boundary-value problem and verified numerical behavior.

### R2. Improve wording and readability

- [x] Correct typographical and grammatical errors.
- [x] Shorten awkward sentences, remove repetition, and standardize mathematical terminology.
- [x] Ensure each major section states its purpose, assumptions, and conclusion clearly.

**Status:** Complete. Front matter, chapter framing, core derivations, results discussion, glossary definitions, and appendix captions now use concise and consistent prose.

### R3. Normalize layout and formatting

- [x] Replace forced `\\` paragraph breaks with semantic paragraphs.
- [x] Normalize filename capitalization, cross-reference names, labels, captions, and glossary display names.
- [x] Correct preamble configuration and eliminate actionable LaTeX warnings.
- [x] Generate both glossaries, verify the complete build, and inspect the resulting PDF.

**Status:** Complete. The reproducible build now produces an 87-page PDF with nomenclature and terminology entries, no overfull boxes, and no missing or undefined references.

**Value:** Medium. Produces an accurate, portable, professional report after numerical claims are trustworthy.

## Priority 5: Maintainability

### C1. Simplify ownership boundaries

- Keep problem construction, validation, assembly, solution, error analysis, and presentation separate.
- Remove duplicate calculations and obsolete compatibility terminology.
- Standardize naming without changing public entry points unnecessarily.

### C2. Complete project documentation

- Keep `README.md` limited to current setup and commands.
- Keep `MODERNIZATION_PLAN.md` synchronized with completed milestones and next work.
- Move durable findings into `docs/`; remove stale generated logs and historical claims from tracked documentation.

## Completion Gates

- MATLAB tests pass with independent constant- and variable-coefficient correctness coverage.
- Corrected norms and convergence orders agree with theory.
- Performance is no worse on small cases and demonstrably better at scale.
- `latexmk` completes without actionable warnings, and the PDF is visually reviewed.
- This plan, affected report sections, README, modernization plan, tests, and benchmarks agree.
