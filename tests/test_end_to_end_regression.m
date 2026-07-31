function tests = test_end_to_end_regression
%TEST_END_TO_END_REGRESSION Verify convergence trends for baseline setup.

tests = functiontests(localfunctions);
end

function testErrorImprovesWithRefinement(~)
num_Elements = [4 8];
q_Type = 'q_Const';
q_Coeff = 1;
load_Coeff = [1 2 -3];
delta = 0;
P = 0.01;

[h, ~, q_Func, load_Func, ~, u_FEM_Lin, u_FEM_Cub, u_Exact, relTol] = ...
    Def_Problem(num_Elements, q_Type, load_Coeff, q_Coeff, delta, P);

for idx = 1:numel(num_Elements)
    [u_FEM_Lin{idx}, u_FEM_Cub{idx}] = Calc_FEM_Sol( ...
        num_Elements(idx), h(idx), delta, P, q_Func, load_Func, relTol);
end

errLin4 = ComputeL2Error(u_Exact, u_FEM_Lin{1}, num_Elements(1), relTol);
errLin8 = ComputeL2Error(u_Exact, u_FEM_Lin{2}, num_Elements(2), relTol);
errCub4 = ComputeL2Error(u_Exact, u_FEM_Cub{1}, num_Elements(1), relTol);
errCub8 = ComputeL2Error(u_Exact, u_FEM_Cub{2}, num_Elements(2), relTol);

assert(errLin8 < errLin4, 'Linear FEM error did not improve with refinement.');
assert(errCub8 < errCub4, 'Cubic FEM error did not improve with refinement.');
assert(errCub8 < errLin8, 'Cubic FEM should outperform linear FEM for this baseline case.');
end

function testBoundaryConditionsAreRespected(~)
num_Elements = 8;
q_Type = 'q_Const';
q_Coeff = 1;
load_Coeff = [1 2 -3];
delta = 0;
P = 0.01;

[h, ~, q_Func, load_Func, ~, ~, ~, ~, relTol] = ...
    Def_Problem(num_Elements, q_Type, load_Coeff, q_Coeff, delta, P);

[uLin, uCub] = Calc_FEM_Sol(num_Elements, h, delta, P, q_Func, load_Func, relTol);

assert(abs(uLin{1}(0) - delta) < 1e-10, 'Linear FEM left Dirichlet value mismatch.');
assert(abs(uCub{1}(0) - delta) < 1e-10, 'Cubic FEM left Dirichlet value mismatch.');
assert(isfinite(uLin{end}(1)), 'Linear FEM right-end value is not finite.');
assert(isfinite(uCub{end}(1)), 'Cubic FEM right-end value is not finite.');
end

function testComputeApiHasNoPlottingSideEffects(~)
num_Elements = [4 8 16];
q_Type = 'q_Const';
q_Coeff = 1;
load_Coeff = [1 2 -3];
delta = 0;
P = 0.01;

num_Figures_Before = numel(findall(0, 'Type', 'figure'));

femData = Compute_FEM_Data(num_Elements, q_Type, q_Coeff, load_Coeff, delta, P);

num_Figures_After = numel(findall(0, 'Type', 'figure'));

assert(num_Figures_After == num_Figures_Before, ...
    'Compute_FEM_Data should not create figures.');
assert(isfield(femData, 'u_FEM_Lin') && numel(femData.u_FEM_Lin) == numel(num_Elements), ...
    'Compute_FEM_Data linear field output mismatch.');
assert(isfield(femData, 'u_FEM_Cub') && numel(femData.u_FEM_Cub) == numel(num_Elements), ...
    'Compute_FEM_Data cubic field output mismatch.');
assert(all(femData.l2_Error_Lin > 0), ...
    'Compute_FEM_Data linear L2 error norms should be positive.');
assert(all(femData.l2_Error_Cub > 0), ...
    'Compute_FEM_Data cubic L2 error norms should be positive.');
assert(ischar(femData.q_Type) && strcmp(femData.q_Type, 'q_const'), ...
    'Compute_FEM_Data should preserve the normalized q-type identifier.');
end

function testBuildProblemDataAcceptsSpaceSeparatedAlias(~)
num_Elements = [4 8];
[qMeshSize, ~, ~, ~, ~, ~, ~, ~, ~] = Build_Problem_Data( ...
    num_Elements, 'q const', [1 2 -3], 1, 0, 0.01);
assert(isequal(size(qMeshSize), size(num_Elements)), ...
    'Build_Problem_Data should accept space-separated q-type aliases.');
end

function testNormalizeQTypeRejectsWhitespaceOnlyAlias(testCase)
verifyError(testCase, @() Normalize_Q_Type('   '), 'Normalize_Q_Type:InvalidQType');
end

function testBuildProblemDataRejectsCharMatrixQType(testCase)
verifyError(testCase, @() Build_Problem_Data( ...
    [4 8], char('q', 'const'), [1 2 -3], 1, 0, 0.01), ...
    'Build_Problem_Data:InvalidQType');
end

function testBuildProblemDataRejectsEmptyQType(testCase)
verifyError(testCase, @() Build_Problem_Data([4 8], '', [1 2 -3], 1, 0, 0.01), ...
    'Build_Problem_Data:InvalidQType');
end

function testBuildProblemDataRejectsNonStringQType(testCase)
verifyError(testCase, @() Build_Problem_Data([4 8], 42, [1 2 -3], 1, 0, 0.01), ...
    'Build_Problem_Data:InvalidQType');
end

function testBuildProblemDataRejectsComplexQCoeff(testCase)
verifyError(testCase, @() Build_Problem_Data([4 8], 'constant', [1 2 -3], [1+1i], 0, 0.01), ...
    'Build_Problem_Data:InvalidQCoeff');
end

function testBuildProblemDataRejectsComplexBoundaryData(testCase)
verifyError(testCase, @() Build_Problem_Data([4 8], 'constant', [1 2 -3], 1, 0+1i, 0.01), ...
    'Build_Problem_Data:InvalidBoundaryData');
end

function testComputeFEMDataRejectsNonFiniteBoundaryData(testCase)
verifyError(testCase, @() Compute_FEM_Data([4 8], 'constant', 1, [1 2 -3], NaN, 0), ...
    'Compute_FEM_Data:InvalidBoundaryData');
end

function testComputeFEMDataRejectsNonFiniteCoefficients(testCase)
verifyError(testCase, @() Compute_FEM_Data([4 8], 'constant', [1 NaN], [1 2 -3], 0, 0.01), ...
    'Compute_FEM_Data:InvalidQCoeff');
end

function testDefProblemRejectsNonFiniteBoundaryData(testCase)
verifyError(testCase, @() Def_Problem([4 8], 'constant', [1 2 -3], 1, NaN, 0.01), ...
    'Def_Problem:InvalidBoundaryData');
end

function testCalcFEMSolRejectsNonFiniteMeshSize(testCase)
verifyError(testCase, @() Calc_FEM_Sol(4, NaN, 0, 0.01, @(x) 1, @(x) 1, 1e-12), ...
    'Calc_FEM_Sol:InvalidMeshSize');
end

function testBuildLocalSolutionRejectsNonFiniteCoefficients(testCase)
psi = {@(x) 1, @(x) x};
verifyError(testCase, @() Build_Local_Solution(1, 2, [1 NaN], psi), ...
    'Build_Local_Solution:InvalidCoefficients');
end

function testElemContRejectsNonFiniteRelTol(testCase)
psiLin = {@(x) 1, @(x) x};
psiPrimeLin = {@(x) 1, @(x) 1};
verifyError(testCase, @() Elem_Cont(0.25, 1, @(x) 1, @(x) 1, ...
    psiLin, psiPrimeLin, psiLin, psiPrimeLin, NaN), ...
    'Elem_Cont:InvalidRelTol');
end

function testComputeErrorSummaryRejectsNonFiniteRelTol(testCase)
validFields = {{@(x) x}, {@(x) x}};
verifyError(testCase, @() Compute_Error_Summary( ...
    [4 8], @(x) x, validFields, validFields, NaN), ...
    'Compute_Error_Summary:InvalidRelTol');
end

function testComputeErrorSummaryRejectsNonCallableFEMFields(testCase)
invalidFields = {{1}, {@(x) x}};
validFields = {{@(x) x}, {@(x) x}};
verifyError(testCase, @() Compute_Error_Summary( ...
    [4 8], @(x) x, invalidFields, validFields, 1e-12), ...
    'Compute_Error_Summary:InvalidFEMFields');
end

function testSolveEqSysRejectsNonFiniteMeshSize(testCase)
verifyError(testCase, @() Solve_Eq_Sys(4, NaN, 0, 0.01, ...
    @(x) 1, @(x) 1, {@(x) 1, @(x) x}, {@(x) 1, @(x) 1}, ...
    {@(x) 1, @(x) x, @(x) x.^2, @(x) x.^3}, ...
    {@(x) 1, @(x) 1, @(x) x, @(x) x.^2}, 1e-12), ...
    'Solve_Eq_Sys:InvalidMeshSize');
end

function testConvergenceRatesExceedThresholds(~)
num_Elements = [4 8 16 32];
q_Type = 'q_Const';
q_Coeff = 1;
load_Coeff = [1 2 -3];
delta = 0;
P = 0.01;

femData = Compute_FEM_Data(num_Elements, q_Type, q_Coeff, load_Coeff, delta, P);

% Explicit rate thresholds tuned from baseline behavior with safety margin.
lin_Min = 2.5;
cub_Min = 9.0;

assert(all(femData.conv_Factor_Lin >= lin_Min), ...
    'Linear convergence factor fell below threshold.');
assert(all(femData.conv_Factor_Cub >= cub_Min), ...
    'Cubic convergence factor fell below threshold.');
end

function testPointwiseBoundaryFluxResidualsConverge(~)
num_Elements = [8 16 32];
q_Type = 'q_Const';
q_Coeff = 1;
load_Coeff = [1 2 -3];
delta = 0;
P = 0.01;

[meshSize, ~, q_Func, load_Func, ~, ~, ~, ~, relTol] = ...
    Def_Problem(num_Elements, q_Type, load_Coeff, q_Coeff, delta, P);

resLin = zeros(size(num_Elements));
resCub = zeros(size(num_Elements));

for idx = 1:numel(num_Elements)
    numElem = num_Elements(idx);
    [uLin, uCub] = Calc_FEM_Sol( ...
        numElem, meshSize(idx), delta, P, q_Func, load_Func, relTol);

    resLin(idx) = abs(ComputeRightBoundaryResidual( ...
        uLin{numElem}, meshSize(idx), q_Func, P));
    resCub(idx) = abs(ComputeRightBoundaryResidual( ...
        uCub{numElem}, meshSize(idx), q_Func, P));
end

assert(all(diff(resLin) < 0), ...
    'Linear right-boundary residual should decrease with mesh refinement.');
assert(all(diff(resCub) < 0), ...
    'Cubic right-boundary residual should decrease with mesh refinement.');
assert(resLin(end) <= 1e-3, ...
    'Linear right-boundary residual exceeded finest-mesh threshold.');
end

function err = ComputeL2Error(u_Exact, local_Fields, N, relTol)

h = 1 / N;
accum = 0;
for elem_No = 1:N
    global_Coord = @(y) (elem_No - 1 + y) .* h;
    sqErr = @(y) (u_Exact(global_Coord(y)) - local_Fields{elem_No}(y)).^2;
    accum = accum + h * quadgk(sqErr, 0, 1, 'RelTol', relTol);
end
err = sqrt(accum);
end

function residual = ComputeRightBoundaryResidual(localField, h, q_Func, P)

dy = 1e-6;
dUdy = (localField(1) - localField(1 - dy)) / dy;
dUdx = dUdy / h;
residual = q_Func(1) * dUdx - P;
end
