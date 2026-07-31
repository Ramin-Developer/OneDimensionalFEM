function tests = test_quadrature_selection
%TEST_QUADRATURE_SELECTION Verify fixed Gauss use and adaptive fallback.

tests = functiontests(localfunctions);
end

function testSmoothModelsUseFixedGauss(~)
[psiLin, psiPrimeLin, psiCub, psiPrimeCub] = Def_FEM_Func;
[~, ~, ~, ~, mode] = Elem_Cont( ...
    0.25, 2, @(x) exp(-0.7 .* x), @(x) 1 + x + x.^2, ...
    psiLin, psiPrimeLin, psiCub, psiPrimeCub, 1e-12);

assert(strcmp(mode, 'fixed-gauss'));
end

function testDifficultRationalModelUsesAdaptiveFallback(~)
[psiLin, psiPrimeLin, psiCub, psiPrimeCub] = Def_FEM_Func;
[KLin, bLin, KCub, bCub, mode] = Elem_Cont( ...
    0.25, 1, @(x) 1 ./ (x + 1e-4), @(x) 1 + x + x.^2, ...
    psiLin, psiPrimeLin, psiCub, psiPrimeCub, 1e-12);

assert(strcmp(mode, 'adaptive'));
assert(all(isfinite(KLin(:))) && all(isfinite(bLin(:))));
assert(all(isfinite(KCub(:))) && all(isfinite(bCub(:))));
end

function testAssemblyStatsCountQuadratureModes(~)
numElements = 8;
[~, ~, stats] = Calc_FEM_Sol( ...
    numElements, 1 / numElements, 0, 0.01, ...
    @(x) 1 + x, @(x) 1 + 2 .* x - 3 .* x.^2, 1e-12);

assert(stats.fixed_Quadrature_Elements == numElements);
assert(stats.adaptive_Quadrature_Elements == 0);
end