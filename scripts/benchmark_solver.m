function timings = benchmark_solver()
%BENCHMARK_SOLVER Basic runtime benchmark for solver scaling.
%
%   Runs the current baseline setup for increasing mesh sizes and prints
%   elapsed time per solve. Intended for quick relative comparisons.

addpath(genpath('src/matlab'));

num_Elements_List = [8 16 32 64];
q_Type = 'q_Const';
q_Coeff = 1;
load_Coeff = [1 2 -3];
delta = 0;
P = 0.01;

[h, ~, q_Func, load_Func, ~, ~, ~, ~, relTol] = ...
    Def_Problem(num_Elements_List, q_Type, load_Coeff, q_Coeff, delta, P);

timings = zeros(numel(num_Elements_List), 2);

for idx = 1:numel(num_Elements_List)
    N = num_Elements_List(idx);
    tic;
    Calc_FEM_Sol(N, h(idx), delta, P, q_Func, load_Func, relTol);
    elapsed = toc;

    timings(idx, 1) = N;
    timings(idx, 2) = elapsed;
end

disp('N        elapsed_seconds');
disp(timings);
