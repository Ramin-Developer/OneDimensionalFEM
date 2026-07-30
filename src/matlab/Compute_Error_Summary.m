function [sq_Error_Lin, sq_Error_Cub, conv_Factor_Lin, conv_Factor_Cub] = ...
    Compute_Error_Summary(numElements, uExact, uFEMLin, uFEMCub, relTol)
%COMPUTE_ERROR_SUMMARY Compute squared errors and convergence factors.
%
%   [sq_Error_Lin, sq_Error_Cub, conv_Factor_Lin, conv_Factor_Cub] = ...
%       COMPUTE_ERROR_SUMMARY(numElements, uExact, uFEMLin, uFEMCub, relTol)
%   summarizes the FEM solution quality for each mesh.

assert(isnumeric(numElements) && isvector(numElements) && ~isempty(numElements), ...
    'Compute_Error_Summary:InvalidNumElements', ...
    'numElements must be a non-empty numeric vector.');
assert(isa(uExact, 'function_handle'), ...
    'Compute_Error_Summary:InvalidExactSolution', ...
    'uExact must be a function handle.');
assert(iscell(uFEMLin) && iscell(uFEMCub), ...
    'Compute_Error_Summary:InvalidFEMFields', ...
    'FEM field inputs must be cell arrays.');
assert(all(cellfun(@(c) iscell(c), {uFEMLin, uFEMCub})), ...
    'Compute_Error_Summary:InvalidFEMFields', ...
    'FEM field inputs must be cell arrays.');
size_N = length(numElements);
assert(numel(uFEMLin) == size_N && numel(uFEMCub) == size_N, ...
    'Compute_Error_Summary:InvalidFEMFieldCount', ...
    'FEM field inputs must provide one entry per mesh size.');
assert(isnumeric(relTol) && isscalar(relTol) && relTol > 0, ...
    'Compute_Error_Summary:InvalidRelTol', ...
    'relTol must be a positive numeric scalar.');
tot_Error = zeros(2, size_N);

for size_Ind = 1:size_N
    N = numElements(size_Ind);
    tot_Error(1, size_Ind) = Integrate_Squared_Error( ...
        uExact, uFEMLin{size_Ind}, N, relTol);
    tot_Error(2, size_Ind) = Integrate_Squared_Error( ...
        uExact, uFEMCub{size_Ind}, N, relTol);
end

tot_Error = sqrt(tot_Error);
sq_Error_Lin = tot_Error(1, :);
sq_Error_Cub = tot_Error(2, :);

if size_N > 1
    conv_Factor = tot_Error(:, 1:end - 1) ./ tot_Error(:, 2:end);
    conv_Factor_Lin = conv_Factor(1, :);
    conv_Factor_Cub = conv_Factor(2, :);
else
    conv_Factor_Lin = [];
    conv_Factor_Cub = [];
end

function sq_Error = Integrate_Squared_Error(uExact, localFields, N, relTol)

h = 1 / N;
sq_Error = 0;

for elemNo = 1:N
    globalCoord = @(y) (elemNo - 1 + y) .* h;
    sq_ErrorLocal = @(y) ...
        (uExact(globalCoord(y)) - localFields{elemNo}(y)).^2;
    sq_Error = sq_Error + quadgk(sq_ErrorLocal, 0, 1, 'RelTol', relTol);
end
