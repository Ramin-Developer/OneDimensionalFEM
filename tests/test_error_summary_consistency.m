function tests = test_error_summary_consistency
%TEST_ERROR_SUMMARY_CONSISTENCY Verifies shared error-summary behavior.

tests = functiontests(localfunctions);
end

function setupOnce(~)
testDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(testDir);
addpath(genpath(fullfile(repoRoot, 'src', 'matlab')));
end

function testComputeFEMDataExposesConsistentErrorSummary(~)

numElements = [4 8];
q_Type = 'constant';
q_Coeff = 1;
load_Coeff = 1;
delta = 0;
P = 0;

fem_Data = Compute_FEM_Data(numElements, q_Type, q_Coeff, load_Coeff, delta, P);

assert(exist('Compute_Error_Summary', 'file') == 2, 'A shared error-summary helper should be available.');
assert(isequal(size(fem_Data.l2_Error_Lin), [1 2]), 'Linear error summary should have one value per mesh.');
assert(isequal(size(fem_Data.l2_Error_Cub), [1 2]), 'Cubic error summary should have one value per mesh.');
assert(isequal(size(fem_Data.convergence_Factor_Lin), [1 1]), ...
    'Linear reduction factors should have one value for two meshes.');
assert(isequal(size(fem_Data.convergence_Factor_Cub), [1 1]), ...
    'Cubic reduction factors should have one value for two meshes.');
assert(isequal(size(fem_Data.convergence_Order_Lin), [1 1]), ...
    'Linear observed orders should have one value for two meshes.');
assert(isequal(size(fem_Data.convergence_Order_Cub), [1 1]), ...
    'Cubic observed orders should have one value for two meshes.');
assert(all(isfinite(fem_Data.l2_Error_Lin)), 'Linear error values must be finite.');
assert(all(isfinite(fem_Data.l2_Error_Cub)), 'Cubic error values must be finite.');
assert(all(isfinite(fem_Data.convergence_Factor_Lin)), ...
    'Linear reduction factors must be finite.');
assert(all(isfinite(fem_Data.convergence_Factor_Cub)), ...
    'Cubic reduction factors must be finite.');
assert(all(isfinite(fem_Data.convergence_Order_Lin)), ...
    'Linear observed orders must be finite.');
assert(all(isfinite(fem_Data.convergence_Order_Cub)), ...
    'Cubic observed orders must be finite.');
assert(~isfield(fem_Data, 'sq_Error_Lin') && ~isfield(fem_Data, 'sq_Error_Cub'), ...
    'Misleading squared-error aliases must not be exposed.');
assert(~isfield(fem_Data, 'conv_Factor_Lin') && ~isfield(fem_Data, 'conv_Factor_Cub'), ...
    'Abbreviated convergence-factor aliases must not be exposed.');
end

function testComputesPhysicalL2NormIndependentlyOfMesh(~)
numElements = [1 4];
zeroFields = {{@(y) 0}, {@(y) 0, @(y) 0, @(y) 0, @(y) 0}};
expectedNorm = 1 / sqrt(3);

[errorLin, errorCub, convergenceLin, convergenceCub, orderLin, orderCub] = ...
    Compute_Error_Summary( ...
    numElements, @(x) x, zeroFields, zeroFields, 1e-10);

assert(max(abs(errorLin - expectedNorm)) < 1e-10, ...
    'The linear error must equal the physical L2 norm on every mesh.');
assert(max(abs(errorCub - expectedNorm)) < 1e-10, ...
    'The cubic error must equal the physical L2 norm on every mesh.');
assert(abs(convergenceLin - 1) < 1e-10, ...
    'A mesh-independent approximation must have convergence factor one.');
assert(abs(convergenceCub - 1) < 1e-10, ...
    'A mesh-independent approximation must have convergence factor one.');
assert(abs(orderLin) < 1e-10 && abs(orderCub) < 1e-10, ...
    'A mesh-independent approximation must have observed order zero.');
end

function testRejectsEmptyMeshVector(testCase)
verifyError(testCase, @() Compute_Error_Summary([], @(x) x, {}, {}, 1e-8), ...
    'Compute_Error_Summary:InvalidNumElements');
end

function testObservedOrderSupportsNonDoublingMeshes(~)
numElements = [2 6];
coarseFields = {@(y) 1/4 + 0 .* y, @(y) 1/4 + 0 .* y};
fineFields = repmat({@(y) 1/36 + 0 .* y}, 1, 6);

[~, ~, factorLin, factorCub, orderLin, orderCub] = ...
    Compute_Error_Summary(numElements, @(x) 0 .* x, ...
    {coarseFields, fineFields}, {coarseFields, fineFields}, 1e-10);

assert(abs(factorLin - 9) < 1e-10 && abs(factorCub - 9) < 1e-10);
assert(abs(orderLin - 2) < 1e-10 && abs(orderCub - 2) < 1e-10, ...
    'Observed order must account for arbitrary mesh-size ratios.');
end

function testFormattedOutputUsesCanonicalLabels(~)
previousVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');
cleanup = onCleanup(@() RestoreFigureState(previousVisibility));
numElements = [1 2];
solutionSize = 4;
x = linspace(0, 1, solutionSize + 1)';
zeroFields = {{@(y) 0 .* y}, {@(y) 0 .* y, @(y) 0 .* y}};

consoleText = evalc(['[linearText, cubicText] = Show_Results(' ...
    'numElements, solutionSize, x, @(x) x, zeroFields, zeroFields, 1e-10);']);

assert(ischar(linearText) && ischar(cubicText));
assert(~isempty(strfind(consoleText, 'L2 Error Norm')));
assert(~isempty(strfind(consoleText, 'Error Reduction Factor')));
assert(~isempty(strfind(consoleText, 'Observed Order')));
assert(isempty(strfind(consoleText, 'Squared Error')));
assert(~isempty(cleanup));
end

function testRejectsMismatchedFEMFieldCount(testCase)
verifyError(testCase, @() Compute_Error_Summary([4 8], @(x) x, { @(x) x }, { @(x) x, @(x) x }, 1e-8), ...
    'Compute_Error_Summary:InvalidFEMFieldCount');
end

function testRejectsNonCallableFEMFieldEntries(testCase)
invalidFields = {{1}, {@(x) x}};
validFields = {{@(x) x}, {@(x) x}};
verifyError(testCase, @() Compute_Error_Summary( ...
    [4 8], @(x) x, invalidFields, validFields, 1e-8), ...
    'Compute_Error_Summary:InvalidFEMFields');
end

function RestoreFigureState(previousVisibility)
close('all');
set(0, 'DefaultFigureVisible', previousVisibility);
end
