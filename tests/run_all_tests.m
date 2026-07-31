function results = run_all_tests()
%RUN_ALL_TESTS Execute repository MATLAB tests.
%
%   Intended for MATLAB R2017a-compatible local and CI usage.

addpath(genpath('src/matlab'));
addpath('tests');

results = runtests('tests');

testFiles = dir(fullfile('tests', 'test_*.m'));
resultNames = {results.Name};
for idx = 1:numel(testFiles)
    [~, testName] = fileparts(testFiles(idx).name);
    assert(any(strncmp(resultNames, [testName '/'], numel(testName) + 1)), ...
        'run_all_tests:ExcludedTestFile', ...
        'Test file was excluded from the suite: %s', testFiles(idx).name);
end

if ~all([results.Passed])
    error('run_all_tests:Failed', 'One or more tests failed.');
end
