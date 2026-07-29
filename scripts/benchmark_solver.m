function timings = benchmark_solver(repeatCount, numElementsList)
%BENCHMARK_SOLVER Runtime benchmark with repeat-count statistics.
%
%   timings = BENCHMARK_SOLVER() runs baseline benchmark for a default mesh
%   list and reports min/median/max elapsed seconds over repeated solves.
%
%   timings = BENCHMARK_SOLVER(repeatCount, numElementsList) customizes the
%   number of repeats and mesh sizes. timings is an N-by-4 matrix:
%   [numElements, minSeconds, medianSeconds, maxSeconds].

addpath(genpath('src/matlab'));

if nargin < 1 || isempty(repeatCount)
    repeatCount = 5;
end
if nargin < 2 || isempty(numElementsList)
    numElementsList = [8 16 32 64];
end

assert(isnumeric(repeatCount) && isscalar(repeatCount) ...
    && repeatCount >= 1 && mod(repeatCount, 1) == 0, ...
    'benchmark_solver:InvalidRepeatCount', ...
    'repeatCount must be a positive integer scalar.');
assert(isnumeric(numElementsList) && isvector(numElementsList) ...
    && ~isempty(numElementsList) && all(numElementsList > 0) ...
    && all(mod(numElementsList, 1) == 0), ...
    'benchmark_solver:InvalidNumElementsList', ...
    'numElementsList must be a non-empty vector of positive integers.');

q_Type = 'q_Const';
q_Coeff = 1;
load_Coeff = [1 2 -3];
delta = 0;
P = 0.01;

[h, ~, q_Func, load_Func, ~, ~, ~, ~, relTol] = ...
    Def_Problem(numElementsList, q_Type, load_Coeff, q_Coeff, delta, P);

timings = zeros(numel(numElementsList), 4);

for idx = 1:numel(numElementsList)
    N = numElementsList(idx);
    repeats = zeros(repeatCount, 1);

    for rep = 1:repeatCount
        tic;
        Calc_FEM_Sol(N, h(idx), delta, P, q_Func, load_Func, relTol);
        repeats(rep) = toc;
    end

    minSec = min(repeats);
    medSec = median(repeats);
    maxSec = max(repeats);

    timings(idx, 1) = N;
    timings(idx, 2) = minSec;
    timings(idx, 3) = medSec;
    timings(idx, 4) = maxSec;
end

disp('N        min_seconds    median_seconds    max_seconds');
disp(timings);

end
