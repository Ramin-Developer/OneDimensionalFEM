function tests = test_error_summary_consistency
%TEST_ERROR_SUMMARY_CONSISTENCY Verifies shared error-summary behavior.

tests = functiontests(localfunctions);

function testComputeFEMDataExposesConsistentErrorSummary(~)
addpath(genpath('src/matlab'));

numElements = [4 8];
q_Type = 'constant';
q_Coeff = 1;
load_Coeff = 1;
delta = 0;
P = 0;

fem_Data = Compute_FEM_Data(numElements, q_Type, q_Coeff, load_Coeff, delta, P);

assert(exist('Compute_Error_Summary', 'file') == 2, 'A shared error-summary helper should be available.');
assert(isequal(size(fem_Data.sq_Error_Lin), [1 2]), 'Linear error summary should have one value per mesh.');
assert(isequal(size(fem_Data.sq_Error_Cub), [1 2]), 'Cubic error summary should have one value per mesh.');
assert(isequal(size(fem_Data.conv_Factor_Lin), [1 1]), 'Linear convergence factors should have one value for two meshes.');
assert(isequal(size(fem_Data.conv_Factor_Cub), [1 1]), 'Cubic convergence factors should have one value for two meshes.');
assert(all(isfinite(fem_Data.sq_Error_Lin)), 'Linear error values must be finite.');
assert(all(isfinite(fem_Data.sq_Error_Cub)), 'Cubic error values must be finite.');
assert(all(isfinite(fem_Data.conv_Factor_Lin)), 'Linear convergence factors must be finite.');
assert(all(isfinite(fem_Data.conv_Factor_Cub)), 'Cubic convergence factors must be finite.');

function testRejectsEmptyMeshVector(~)
verifyError(@() Compute_Error_Summary([], @(x) x, {}, {}, 1e-8), ...
    'Compute_Error_Summary:InvalidNumElements');
end

function testRejectsMismatchedFEMFieldCount(~)
verifyError(@() Compute_Error_Summary([4 8], @(x) x, { @(x) x }, { @(x) x, @(x) x }, 1e-8), ...
    'Compute_Error_Summary:InvalidFEMFieldCount');
end

function testRejectsNonCallableFEMFieldEntries(~)
verifyError(@() Compute_Error_Summary([4 8], @(x) x, { 1 }, { @(x) x, @(x) x }, 1e-8), ...
    'Compute_Error_Summary:InvalidFEMFields');
end
