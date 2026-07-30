function tests = test_smoke_main_program
%TEST_SMOKE_MAIN_PROGRAM Basic availability checks for core entry points.

tests = functiontests(localfunctions);

function testMainProgramExists(~)
assert(exist('Main_Program', 'file') == 2, 'Main_Program.m not found on MATLAB path.');

function testCoreFunctionsExist(~)
assert(exist('Def_Problem', 'file') == 2, 'Def_Problem.m not found on MATLAB path.');
assert(exist('Solve_Eq_Sys', 'file') == 2, 'Solve_Eq_Sys.m not found on MATLAB path.');
assert(exist('Show_Results', 'file') == 2, 'Show_Results.m not found on MATLAB path.');
assert(exist('Compute_FEM_Data', 'file') == 2, 'Compute_FEM_Data.m not found on MATLAB path.');
assert(exist('Plot_FEM_Solutions', 'file') == 2, 'Plot_FEM_Solutions.m not found on MATLAB path.');

function testBuildLocalSolutionRejectsInsufficientCoefficients(~)
addpath(genpath('src/matlab'));
verifyError(@() Build_Local_Solution(1, 2, [1 2], { @(x) x, @(x) 1 }), ...
    'Build_Local_Solution:InvalidCoefficients');
end

function testBuildProblemDataRejectsEmptyCoefficients(~)
addpath(genpath('src/matlab'));
verifyError(@() Build_Problem_Data([4 8], 'constant', [], [], 0, 0), ...
    'Build_Problem_Data:InvalidLoadCoeff');
verifyError(@() Build_Problem_Data([4 8], 'constant', 1, [], 0, 0), ...
    'Build_Problem_Data:InvalidQCoeff');
end

function testBuildLocalSolutionRejectsInvalidBasisHandles(~)
addpath(genpath('src/matlab'));
verifyError(@() Build_Local_Solution(1, 2, [1 2 3], { @(x) x, 1 }), ...
    'Build_Local_Solution:InvalidBasis');
end

function testCalcFEMSolRejectsInsufficientCoefficientsViaStub(~)
addpath(genpath('src/matlab'));
addpath('tests/stubs');
verifyError(@() Calc_FEM_Sol(2, 0.5, 0, 0, @(x) 1, @(x) 1, 1e-8), ...
    'Calc_FEM_Sol:InvalidCoefficientVector');
end