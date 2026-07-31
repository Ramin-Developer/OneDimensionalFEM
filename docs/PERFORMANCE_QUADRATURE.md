# Shared Gauss Quadrature Performance

## Method

Element assembly evaluates 16- and 32-point Gauss-Legendre rules using shared mapped coordinates, rigidity/load values, and basis values. The 32-point contributions are accepted when both orders agree within five times the requested relative tolerance. Difficult elements retain the previous adaptive `quadgk` path.

## Results

The benchmark uses MATLAB R2017a, constant rigidity, a quadratic load, and three repeats per mesh size. P1 sparse assembly is the baseline.

| Elements | Sparse/adaptive median | Shared Gauss median | Improvement |
|---:|---:|---:|---:|
| 64 | 0.3223 s | 0.0251 s | 92.2% |
| 128 | 0.6469 s | 0.0405 s | 93.7% |
| 256 | 1.2914 s | 0.0700 s | 94.6% |

All thirteen guarded test files pass without changing golden snapshots. Independent fixed-Gauss and closed-form oracles cover every rigidity family and both basis orders. A near-singular rational case verifies adaptive fallback without warnings.