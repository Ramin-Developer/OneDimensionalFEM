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
assert(isequal(size(fem_Data.conv_Factor_Lin), [1 1]), 'Linear convergence factors should have one value for two meshes.');
assert(isequal(size(fem_Data.conv_Factor_Cub), [1 1]), 'Cubic convergence factors should have one value for two meshes.');
assert(all(isfinite(fem_Data.l2_Error_Lin)), 'Linear error values must be finite.');
assert(all(isfinite(fem_Data.l2_Error_Cub)), 'Cubic error values must be finite.');
assert(all(isfinite(fem_Data.conv_Factor_Lin)), 'Linear convergence factors must be finite.');
assert(all(isfinite(fem_Data.conv_Factor_Cub)), 'Cubic convergence factors must be finite.');
assert(isequal(fem_Data.sq_Error_Lin, fem_Data.l2_Error_Lin), ...
    'The legacy linear error field must remain a compatibility alias.');
assert(isequal(fem_Data.sq_Error_Cub, fem_Data.l2_Error_Cub), ...
    'The legacy cubic error field must remain a compatibility alias.');
end

function testComputesPhysicalL2NormIndependentlyOfMesh(~)
numElements = [1 4];
zeroFields = {{@(y) 0}, {@(y) 0, @(y) 0, @(y) 0, @(y) 0}};
expectedNorm = 1 / sqrt(3);

[errorLin, errorCub, convergenceLin, convergenceCub] = Compute_Error_Summary( ...
    numElements, @(x) x, zeroFields, zeroFields, 1e-10);

assert(max(abs(errorLin - expectedNorm)) < 1e-10, ...
    'The linear error must equal the physical L2 norm on every mesh.');
assert(max(abs(errorCub - expectedNorm)) < 1e-10, ...
    'The cubic error must equal the physical L2 norm on every mesh.');
assert(abs(convergenceLin - 1) < 1e-10, ...
    'A mesh-independent approximation must have convergence factor one.');
assert(abs(convergenceCub - 1) < 1e-10, ...
    'A mesh-independent approximation must have convergence factor one.');
end

function testRejectsEmptyMeshVector(testCase)
verifyError(testCase, @() Compute_Error_Summary([], @(x) x, {}, {}, 1e-8), ...
    'Compute_Error_Summary:InvalidNumElements');
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
