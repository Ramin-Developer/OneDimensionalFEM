# D3 Performance Profiling: Hot Paths and Optimization Opportunities

Date: 2026-07-29
Branch: perf/profile-hotpaths-d3-20260729

## Goal

Profile representative FEM solves and identify high-impact optimization targets.

## Profiling Setup

- MATLAB: R2017a execution mode `-nosplash -nodesktop -wait -r`
- Script: `scripts/profile_solver_hotpaths.m`
- Inputs: `numElementsList = [32, 64]`, `repeatCount = 2`
- Output artifact: `docs/performance_hotspots.txt`

## Measured Hotspots

Total profiled time: `4.15585794432` seconds

Top relevant functions by total time:

1. `Calc_FEM_Sol`: `0.632620695972` s
2. `Solve_Eq_Sys`: `0.618456989345` s
3. `Elem_Cont`: `0.57556986928` s
4. `Elem_Cont>Cal_Cont`: `0.573994368543` s
5. `quadgk`: `0.510424538802` s
6. `quadgk>vadapt`: `0.235059809973` s

Raw profiler table is saved in `docs/performance_hotspots.txt`.

## Interpretation

- The assembly and integration path (`Solve_Eq_Sys` -> `Elem_Cont` -> `Cal_Cont` -> `quadgk`) dominates execution time.
- The adaptive quadrature stack (`quadgk`, `vadapt`, callback evaluation) is a major contributor, indicating integration-call count and integrand cost are the primary levers.
- Linear system solve time is material but appears secondary to integration-heavy assembly.

## Optimization Opportunities (Prioritized)

1. Reduce quadrature call volume in element assembly.
   - In `Elem_Cont`, each `(i, j)` and `i` entry calls `quadgk` separately.
   - Evaluate fixed-order Gauss quadrature for known polynomial basis-function products where acceptable.

2. Hoist repeated per-element computations.
   - Cache mapped coordinates and repeated basis/basis-derivative evaluations for quadrature points.
   - Reduce repeated anonymous-function capture overhead inside nested loops.

3. Introduce optional fast path for constant-coefficient cases.
   - For `q_Const` and polynomial load definitions, precompute reference element integrals and reuse scaled values.

4. Assess sparse-assembly strategy for larger meshes.
   - Global stiffness matrices are currently assembled as dense arrays in `Solve_Eq_Sys`.
   - Test sparse assembly/solve impact for higher `N` while preserving current numerics.

5. Add profiling/benchmark guardrails in CI (D4).
   - Use the existing benchmark workflow and compare median elapsed times against informational thresholds.

## Reproduction Command

```powershell
matlab -nosplash -nodesktop -wait -r "try; cd('d:/repos/Code/OneDimensionalFEM'); addpath('scripts'); profile_solver_hotpaths([32 64],2,10,'docs/performance_hotspots.txt'); catch ME; disp(getReport(ME,'extended')); end; exit"
```