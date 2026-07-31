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
- [x] Add canonical `l2_Error_*` outputs while retaining `sq_Error_*` as compatibility aliases.
- [x] Add an independent analytic norm test and correct duplicated test integration.
- [x] Regenerate affected snapshots and report tables, then validate the complete suite.

**Status:** Complete. Error magnitudes, snapshots, report tables, and terminology now use the physical $L^2$ norm.

### M2. Correct and verify boundary treatment

- Fix the weak form so the natural boundary contribution is $P w(1)$.
- Independently verify linear and cubic boundary residuals.
- Decide whether strongly prescribing the cubic endpoint derivative is mathematically intended; remove it if the natural condition alone is correct.
- Add manufactured-solution tests for constant and variable coefficients.

**Value:** Critical. This controls the mathematical problem being solved and reported.

### M3. Harden coefficient admissibility

- Define valid coefficient counts and domains for every `q_Type`.
- Reject zero exponential parameters, singular rational denominators, non-finite values, and invalid aliases consistently.
- Add positive and negative tests for every supported model.

**Value:** High. Prevents undefined or misleading solutions.

## Priority 2: Trustworthy Verification

### V1. Build an independent numerical oracle

- Test element matrices and loads against closed-form cases rather than production helpers.
- Cover all coefficient families, both basis orders, multiple meshes, and nonzero boundary data.
- Separate compatibility snapshots from correctness assertions.

### V2. Align outputs and terminology

- Use consistent names for squared integrals, norms, convergence factors, and orders.
- Ensure console labels, APIs, tests, plots, tables, and report equations describe the same quantities.
- Record tolerances and their numerical justification.

**Value:** High. Makes later refactoring measurable and reviewable.

## Priority 3: Performance

### P1. Use sparse assembly

- Replace dense global matrices with sparse triplet assembly.
- Benchmark memory and solve time over representative mesh sizes.

### P2. Reduce quadrature cost

- Replace repeated adaptive element integrations with validated fixed-order Gauss quadrature where exactness permits.
- Precompute reference basis products and reuse constant/polynomial element integrals.
- Hoist invariant callbacks and element data out of loops.

### P3. Establish performance gates

- Capture a corrected baseline before optimization.
- Report median runtime and memory scaling; keep CI thresholds informational until stable.

**Value:** Medium to high after correctness. Expected improvement is substantial for large meshes.

## Priority 4: Report Quality

### R1. Correct mathematical statements

- Fix the weak-form endpoint, bilinearity identity, continuity-constant wording, and convergence notation $\mathcal{O}(N^{-2})$.
- Replace the claim that linear FEM cannot satisfy a natural boundary condition with its weak-form interpretation.
- Reconcile every numerical table with corrected code output.

### R2. Improve wording and readability

- Correct typographical and grammatical errors.
- Shorten awkward sentences, remove repetition, and standardize mathematical terminology.
- Ensure each section states its purpose, assumptions, and conclusion clearly.

### R3. Normalize layout and formatting

- Replace forced `\\` paragraph breaks with semantic paragraphs.
- Normalize filename capitalization, cross-reference names, labels, captions, and glossary plurals.
- Correct preamble inclusion and eliminate actionable LaTeX warnings.
- Verify clean `latexmk` builds and inspect the resulting PDF.

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
