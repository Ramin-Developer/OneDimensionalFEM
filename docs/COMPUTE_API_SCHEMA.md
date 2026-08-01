# Compute API Schema

This document defines the stable output schema for `Compute_FEM_Data`.

## Scope

- Producer: `src/matlab/Compute_FEM_Data.m`
- Primary consumers: tests, golden snapshot tooling, benchmarks, and report-data workflows.
- Stability policy: fields listed below are the v1 public contract and should not be renamed or removed without an explicit migration PR.

## Function Contract

```matlab
fem_Data = Compute_FEM_Data(numElements, q_Type, q_Coeff, load_Coeff, delta, P)
```

Input notes:
- `numElements` must be a non-empty vector of positive integers.
- `q_Type` is normalized to canonical lowercase form.
- `delta` and `P` are finite scalar boundary values.

## Output Schema (v1)

The returned struct must contain exactly these fields:

1. `num_Elements`: numeric vector matching requested mesh counts.
2. `mesh_Size`: numeric vector, same size as `num_Elements`.
3. `q_Type`: normalized char identifier.
4. `solution_Size`: numeric vector, same size as `num_Elements`.
5. `x`: numeric vector of nodal coordinates on `[0,1]`.
6. `u_Exact`: function handle for exact solution evaluation.
7. `u_FEM_Lin`: cell array of local linear FEM element functions.
8. `u_FEM_Cub`: cell array of local cubic FEM element functions.
9. `rel_Tol`: finite positive scalar tolerance.
10. `l2_Error_Lin`: finite numeric vector, one value per mesh.
11. `l2_Error_Cub`: finite numeric vector, one value per mesh.
12. `convergence_Factor_Lin`: finite numeric vector for adjacent mesh pairs.
13. `convergence_Factor_Cub`: finite numeric vector for adjacent mesh pairs.
14. `convergence_Order_Lin`: finite numeric vector for adjacent mesh pairs.
15. `convergence_Order_Cub`: finite numeric vector for adjacent mesh pairs.

## Compatibility Rules

- Additive evolution (new optional fields) must be documented in this file and tested.
- Breaking evolution (field rename/removal/type change) requires:
  - schema version bump,
  - consumer migration updates,
  - explicit PR notes.

## Verification

- Contract regression test: `tests/test_compute_api_schema.m`
- Contract snapshot test: `tests/test_compute_api_contract_snapshot.m`
- Snapshot fixture: `tests/golden/compute_api_contract_snapshot.json`
- General suite runner: `tests/run_all_tests.m`
