function results = run_all_tests()
%RUN_ALL_TESTS Execute repository MATLAB tests.
%
%   Intended for MATLAB R2017a-compatible local and CI usage.

results = runtests('tests');

if ~all([results.Passed])
    error('run_all_tests:Failed', 'One or more tests failed.');
end
