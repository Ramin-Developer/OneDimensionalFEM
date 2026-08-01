# Module Contracts (MZ1)

This file defines public MATLAB entry-point contracts and owner boundaries.

## Contract Rules

- Public entry points keep stable input and output shapes unless a PR explicitly announces a contract change.
- Compute paths must remain independent from plotting and report rendering concerns.
- Validation boundaries belong at problem-definition and input gateways, not deep in assembly helpers.

## Public Entry Points

### Main_Program.m

Purpose:
- Orchestrate an interactive run from input capture through solve and presentation.

Input contract:
- No inputs.

Output contract:
- No return values.

Side effects:
- Reads interactive input and renders figures/text output.

Owner:
- Orchestration only. No numerical formulation changes belong here.

### Compute_FEM_Data.m

Purpose:
- Compute a non-interactive FEM result bundle for tests, benchmarking, and downstream evidence.

Input contract:
- Scalar `numElements` and problem parameters (`q_Type`, `q_Coeff`, `load_Coeff`, `delta`, `P`).

Output contract:
- Returns a struct with exact/FEM values, error summaries, and convergence fields used by tests and reports.

Side effects:
- None expected beyond compute-time allocation.

Owner:
- Stable compute API surface for non-UI consumers.

### Def_Problem.m

Purpose:
- Define problem data and validate external problem parameters at the boundary.

Input contract:
- Problem parameters (`q_Type`, `q_Coeff`, `load_Coeff`, `delta`, `P`, `numElements`).

Output contract:
- Returns mesh/solution sizes, function handles, coordinates, initialized FEM vectors, exact solution, and tolerance.

Side effects:
- Throws boundary-scoped `Def_Problem:*` errors for invalid inputs.

Owner:
- Problem setup and validation ownership.

### Calc_FEM_Sol.m

Purpose:
- Coordinate linear and cubic solve paths using prevalidated problem data.

Input contract:
- Validated mesh/problem payload (`numElements`, `meshSize`, `solutionSize`, `qFunc`, `loadFunc`, `x`, `uFEMLin`, `uFEMCub`, `delta`, `P`, `relTol`).

Output contract:
- Returns solved linear and cubic FEM vectors plus assembly statistics.

Side effects:
- None expected.

Owner:
- Compute pipeline coordination only; no plotting.

### Compute_Error_Summary.m

Purpose:
- Produce error and convergence summary values from exact and FEM solutions.

Input contract:
- Exact values and solved FEM vectors with mesh metadata.

Output contract:
- Returns canonical `l2` errors, reduction factors, and observed orders.

Side effects:
- None expected.

Owner:
- Error metric computation and naming consistency.

### Show_Results.m

Purpose:
- Present computed results and delegate plotting.

Input contract:
- Solved values and problem metadata.

Output contract:
- Returns text summary content for linear and cubic modes.

Side effects:
- Writes console output and can produce figures.

Owner:
- Presentation only; should not redefine compute behavior.

### Plot_FEM_Solutions.m

Purpose:
- Render solution figures for exact and FEM curves.

Input contract:
- Coordinates and solved vectors plus metadata.

Output contract:
- No return values.

Side effects:
- Produces figure windows and plot formatting.

Owner:
- Plot rendering only.

## Internal Entry Points (Non-Public)

The following are internal implementation helpers and should change behind public contracts:

- `Build_Problem_Data.m`
- `Solve_Eq_Sys.m`
- `Elem_Cont.m`
- `Build_Local_Solution.m`
- `Def_FEM_Func.m`
- `Basis_Shape_Func.m`
- `Normalize_Q_Type.m`
- `Validate_Input.m`
- `Validate_Q_Coefficients.m`
- `Export_Figure.m`
