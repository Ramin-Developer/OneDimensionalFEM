# Sparse Assembly Performance

## Setup

- MATLAB R2017a
- Constant rigidity with quadratic load
- Three repeats per mesh size
- Runtime statistic: median end-to-end `Calc_FEM_Sol` time
- Memory statistic: combined linear and cubic stiffness-matrix storage before boundary enforcement

## Results

| Elements | Dense baseline (s) | Sparse (s) | Runtime change | Sparse storage | Dense equivalent | Storage ratio |
|---:|---:|---:|---:|---:|---:|---:|
| 64 | 0.3434 | 0.3223 | -6.1% | 17 KB | 169 KB | 10.1% |
| 128 | 0.6559 | 0.6469 | -1.4% | 34 KB | 666 KB | 5.1% |
| 256 | 1.2931 | 1.2914 | -0.2% | 68 KB | 2642 KB | 2.6% |

Sparse matrix storage grows linearly with the element count, while dense-equivalent storage grows quadratically. Runtime remains approximately neutral because adaptive element quadrature, rather than the linear solve, dominates these mesh sizes.

The guarded sparse test additionally verifies maximum nonzero counts of $3N+1$ for the linear matrix and $12N+4$ for the cubic matrix. Independent element and manufactured-solution oracles verify numerical equivalence.