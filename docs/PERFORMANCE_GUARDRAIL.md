# Performance Guardrail

## Policy

The scheduled and manually dispatched CI guardrail is informational: threshold exceedances produce warnings and a job summary but do not fail the workflow. Correctness tests remain the hard gate.

Benchmark timing excludes one warm-up solve per mesh so JIT compilation and persistent Gauss-rule initialization do not distort medians. Five measured repeats are used by default.

## Baseline

Baseline version: `p3-2026-07-31`

| Elements | Reference median | Runtime warning limit | Sparse/dense ratio | Memory warning limit |
|---:|---:|---:|---:|---:|
| 64 | 0.0101 s | 0.0505 s | 0.100686 | 0.110 |
| 128 | 0.0150 s | 0.0750 s | 0.050946 | 0.055 |
| 256 | 0.0282 s | 0.1410 s | 0.025626 | 0.030 |

Runtime limits are five times the local warmed reference to accommodate shared-runner variability. Memory ratios are deterministic and use tighter margins. Custom mesh lists remain informational unless explicit thresholds are supplied.

## Updating

Change `scripts/performance_baseline.m` only after an intentional solver change. Capture at least five warmed repeats, run the complete correctness suite, document the reason, and retain informational limits until results are stable across CI runs.