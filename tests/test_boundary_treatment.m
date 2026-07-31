function tests = test_boundary_treatment
%TEST_BOUNDARY_TREATMENT Verify natural boundary conditions in weak form.

tests = functiontests(localfunctions);
end

function testConstantCoefficientBoundaryRows(~)
qFunc = @(x) 2 + 0 .* x;
loadFunc = @(x) 2 * pi^2 .* sin(pi .* x);
VerifyRightBoundaryRows(qFunc, loadFunc, 0, -2 * pi);
end

function testVariableCoefficientBoundaryRows(~)
qFunc = @(x) 1 + x;
loadFunc = @(x) -(2 + x) .* exp(x);
VerifyRightBoundaryRows(qFunc, loadFunc, 1, 2 * exp(1));
end

function VerifyRightBoundaryRows(qFunc, loadFunc, delta, P)
numElements = 4;
meshSize = 1 / numElements;
relTol = 1e-10;
[psiLin, psiPrimeLin, psiCub, psiPrimeCub] = Def_FEM_Func;

[coeffLin, coeffCub] = Solve_Eq_Sys( ...
    numElements, meshSize, delta, P, qFunc, loadFunc, ...
    psiLin, psiPrimeLin, psiCub, psiPrimeCub, relTol);
[KLin, bLin, KCub, bCub] = Elem_Cont( ...
    meshSize, numElements, qFunc, loadFunc, ...
    psiLin, psiPrimeLin, psiCub, psiPrimeCub, relTol);

idxLin = numElements:numElements + 1;
idxCub = [numElements, numElements + 1, ...
    2 * numElements + 1, 2 * numElements + 2];
residualLin = KLin(2, :) * coeffLin(idxLin) - bLin(2) - P;
residualCubValue = KCub(2, :) * coeffCub(idxCub) - bCub(2) - P;
residualCubSlope = KCub(4, :) * coeffCub(idxCub) - bCub(4);

assert(abs(residualLin) < 1e-9, ...
    'The linear endpoint value row must satisfy the natural boundary load.');
assert(abs(residualCubValue) < 1e-9, ...
    'The cubic endpoint value row must satisfy the natural boundary load.');
assert(abs(residualCubSlope) < 1e-9, ...
    'The cubic endpoint slope row must remain a Galerkin equation.');
end