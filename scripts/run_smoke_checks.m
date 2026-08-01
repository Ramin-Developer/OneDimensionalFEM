function run_smoke_checks()
%RUN_SMOKE_CHECKS Execute fast repository smoke validations.

addpath(genpath('src/matlab'));

assert(exist('Main_Program', 'file') == 2, 'Main_Program.m not found.');
assert(exist('Def_Problem', 'file') == 2, 'Def_Problem.m not found.');
assert(exist('Solve_Eq_Sys', 'file') == 2, 'Solve_Eq_Sys.m not found.');
assert(exist('Show_Results', 'file') == 2, 'Show_Results.m not found.');

Validate_Input('constant', 1, [1 2 -3], 0, 0.01, [4 8 16]);
disp('Smoke checks passed.');

end