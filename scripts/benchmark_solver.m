function [timings, memoryStats] = benchmark_solver(repeatCount, numElementsList)
%BENCHMARK_SOLVER Runtime benchmark with repeat-count statistics.
%
%   timings = BENCHMARK_SOLVER() runs baseline benchmark for a default mesh
%   list and reports min/median/max elapsed seconds over repeated solves.
%
%   timings = BENCHMARK_SOLVER(repeatCount, numElementsList) customizes the
%   number of repeats and mesh sizes. timings is an N-by-4 matrix:
%   [numElements, minSeconds, medianSeconds, maxSeconds]. memoryStats is
%   [numElements, sparseBytes, denseBytes, sparseToDenseRatio].

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
memoryStats = zeros(numel(numElementsList), 4);

for idx = 1:numel(numElementsList)
    N = numElementsList(idx);
    repeats = zeros(repeatCount, 1);

    % Warm up JIT compilation and persistent quadrature data outside timing.
    [~, ~, assemblyStats] = Calc_FEM_Sol( ...
        N, h(idx), delta, P, q_Func, load_Func, relTol);

    for rep = 1:repeatCount
        tic;
        [~, ~, assemblyStats] = Calc_FEM_Sol( ...
            N, h(idx), delta, P, q_Func, load_Func, relTol);
        repeats(rep) = toc;
    end

    minSec = min(repeats);
    medSec = median(repeats);
    maxSec = max(repeats);

    timings(idx, 1) = N;
    timings(idx, 2) = minSec;
    timings(idx, 3) = medSec;
    timings(idx, 4) = maxSec;
    sparseBytes = assemblyStats.linear_Storage_Bytes ...
        + assemblyStats.cubic_Storage_Bytes;
    denseBytes = assemblyStats.linear_Dense_Bytes ...
        + assemblyStats.cubic_Dense_Bytes;
    memoryStats(idx, :) = [N sparseBytes denseBytes sparseBytes / denseBytes];
end

disp('N        min_seconds    median_seconds    max_seconds');
disp(timings);
disp('N        sparse_bytes   dense_bytes    sparse_to_dense');
for idx = 1:size(memoryStats, 1)
    fprintf('%-8d %-14d %-14d %.6f\n', ...
        memoryStats(idx, 1), memoryStats(idx, 2), ...
        memoryStats(idx, 3), memoryStats(idx, 4));
end

end
