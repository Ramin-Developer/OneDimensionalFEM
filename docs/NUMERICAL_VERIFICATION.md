# Numerical Verification

Correctness assertions are independent of compatibility snapshots:

- Constant-coefficient linear and cubic element matrices and load vectors are checked against hard-coded closed-form values.
- Variable-coefficient element contributions are checked with an independent eight-point Gauss-Legendre rule rather than production quadrature helpers.
- Constant, first-denominator, second-denominator, and exponential rigidity families are covered on multiple element locations.
- Manufactured quadratic solutions verify both basis orders, nonzero Dirichlet and natural data, and multiple meshes.

Element comparisons use an absolute tolerance of $10^{-11}$; polynomial cubic solutions use $10^{-10}$. These tolerances are well above double-precision roundoff while remaining small enough to expose mapping, scaling, basis-order, and indexing defects.

Golden MAT files remain compatibility baselines only; they are not the mathematical oracle.
