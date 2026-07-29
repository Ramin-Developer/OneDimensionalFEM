function [factor_Lin, factor_Cub] = ...
    Show_Results(numElements, solutionSize, ...
    x, uExact, uFEMLin, uFEMCub, relTol)

%SHOW_RESULTS Plot FEM results and compute convergence summaries.

assert(isnumeric(numElements) && isvector(numElements) && ~isempty(numElements), ...
    'Show_Results:InvalidNumElements', ...
    'numElements must be a non-empty numeric vector.');
assert(isscalar(solutionSize) && isnumeric(solutionSize) && solutionSize > 0, ...
    'Show_Results:InvalidSolutionSize', ...
    'solutionSize must be a positive numeric scalar.');
assert(isvector(x) && numel(x) == solutionSize + 1, ...
    'Show_Results:InvalidCoordinates', ...
    'x must contain solutionSize + 1 coordinates.');
assert(isa(uExact, 'function_handle'), ...
    'Show_Results:InvalidExactSolution', ...
    'uExact must be a function handle.');
assert(iscell(uFEMLin) && iscell(uFEMCub) ...
    && numel(uFEMLin) == numel(numElements) ...
    && numel(uFEMCub) == numel(numElements), ...
    'Show_Results:InvalidFEMFields', ...
    'FEM field cell arrays must align with numElements length.');
assert(isnumeric(relTol) && isscalar(relTol) && relTol > 0, ...
    'Show_Results:InvalidRelTol', ...
    'relTol must be a positive numeric scalar.');

% Plot exact and FEM-Solution of the problem for different element numbers:
Plot_FEM_Solutions(numElements, solutionSize, x, uExact, uFEMLin, uFEMCub);

% Estimate squared errors and convergence factors:
[factor_Lin, factor_Cub] = ...
    Estimate_Error(numElements, uExact, uFEMLin, uFEMCub, relTol);

assert(all(isfinite(factor_Lin)) && all(isfinite(factor_Cub)), ...
    'Show_Results:InvalidOutput', ...
    'Convergence factors must be finite values.');

function [error_Lin, error_Cub] = ...
    Estimate_Error(numElements, uExact, uFEMLin, uFEMCub, relTol)

size_N = length(numElements);
tot_Error = zeros(2, size_N);

for size_Ind = 1:1:size_N
    numElem = numElements(size_Ind);
    tot_Error(1, size_Ind) = Integrate_Squared_Error( ...
        uExact, uFEMLin{size_Ind}, numElem, relTol);
    tot_Error(2, size_Ind) = Integrate_Squared_Error( ...
        uExact, uFEMCub{size_Ind}, numElem, relTol);
end;

tot_Error = sqrt( tot_Error );
conv_Factor = tot_Error( :, 1:end - 1 ) ./ tot_Error( :, 2:end );

% Display the results:
[error_Lin, error_Cub] = Convert_2_Str(conv_Factor, tot_Error);
disp( error_Lin );
disp( error_Cub );

function [error_Lin, error_Cub] = Convert_2_Str(conv_Factor, sq_Error)

error_Lin = Make_Str( conv_Factor, sq_Error, 1 );
error_Cub = Make_Str( conv_Factor, sq_Error, 3 );

function str_Error_Estimate = Make_Str( conv_Factor, sq_Error, degree )

Title_Error = sprintf( '\tSquared Error            ' );
Title_Conv = sprintf( '\tConvergence Factor        ' );

if degree == 1
    Title  = sprintf( 'Linear Case:');
    Error_Val = sprintf( '%0.4e\t\t\t', sq_Error(1, :) );
    Conv_Val = sprintf( '%0.2e\t\t\t', conv_Factor(1, :) );

elseif degree == 3
    Title  = sprintf( 'Cubic Case:');
    Error_Val = sprintf( '%0.4e\t\t\t', sq_Error(2, :) );
    Conv_Val = sprintf( '%0.2e\t\t\t', conv_Factor(2, :) );

end;

str_Error_Estimate = sprintf( '\n %s \n %s %s \n %s %s', Title, ...
    Title_Error, Error_Val, Title_Conv, Conv_Val);

function sq_Error = Integrate_Squared_Error(uExact, localFields, numElements, relTol)

h = 1 / numElements;
sq_Error = 0;

for elemNo = 1:numElements
    global_Coord = @(y) (elemNo - 1 + y) .* h;
    sq_Error_Local = @(y) ...
        (uExact(global_Coord(y)) - localFields{elemNo}(y)).^2;
    sq_Error = sq_Error + quadgk(sq_Error_Local, 0, 1, 'RelTol', relTol);
end
