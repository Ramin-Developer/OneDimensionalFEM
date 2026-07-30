function tests = test_end_to_end_regression
%TEST_END_TO_END_REGRESSION Verify convergence trends for baseline setup.

tests = functiontests(localfunctions);

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
assert(all(femData.sq_Error_Lin > 0), ...
    'Compute_FEM_Data linear squared-error summary should be positive.');
assert(all(femData.sq_Error_Cub > 0), ...
    'Compute_FEM_Data cubic squared-error summary should be positive.');
assert(ischar(femData.q_Type) && strcmp(femData.q_Type, 'q_const'), ...
    'Compute_FEM_Data should preserve the normalized q-type identifier.');

function testBuildProblemDataAcceptsSpaceSeparatedAlias(~)
num_Elements = [4 8];
[qMeshSize, ~, ~, ~, ~, ~, ~, ~, ~] = Build_Problem_Data( ...
    num_Elements, 'q const', [1 2 -3], 1, 0, 0.01);
assert(isequal(size(qMeshSize), size(num_Elements)), ...
    'Build_Problem_Data should accept space-separated q-type aliases.');

function testComputeFEMDataRejectsNonFiniteBoundaryData(~)
verifyError(@() Compute_FEM_Data([4 8], 'constant', 1, [1 2 -3], NaN, 0), ...
    'Compute_FEM_Data:InvalidBoundaryData');
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

function testRightBoundaryResidualsAreControlled(~)
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
assert(all(resCub <= 1e-6), ...
    'Cubic right-boundary residual exceeded tolerance.');
assert(resLin(end) <= 1e-3, ...
    'Linear right-boundary residual exceeded finest-mesh threshold.');

function err = ComputeL2Error(u_Exact, local_Fields, N, relTol)

h = 1 / N;
accum = 0;
for elem_No = 1:N
    global_Coord = @(y) (elem_No - 1 + y) .* h;
    sqErr = @(y) (u_Exact(global_Coord(y)) - local_Fields{elem_No}(y)).^2;
    accum = accum + quadgk(sqErr, 0, 1, 'RelTol', relTol);
end
err = sqrt(accum);

function residual = ComputeRightBoundaryResidual(localField, h, q_Func, P)

dy = 1e-6;
dUdy = (localField(1) - localField(1 - dy)) / dy;
dUdx = dUdy / h;
residual = q_Func(1) * dUdx - P;
