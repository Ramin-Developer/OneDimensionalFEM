function results = run_smoke_tests()
%RUN_SMOKE_TESTS Execute a lightweight MATLAB smoke suite.
%
% This keeps PR feedback fast by avoiding coverage instrumentation while still
% validating the main entry points and a representative validation path.

addpath(genpath('src/matlab'));
addpath('tests');

smokeTests = {'test_smoke_main_program', 'test_validate_input_negative'};

for idx = 1:numel(smokeTests)
    currentResults = runtests(smokeTests{idx});
    if ~all([currentResults.Passed])
        error('run_smoke_tests:Failed', 'One or more smoke tests failed.');
    end
end

results = [];
end
