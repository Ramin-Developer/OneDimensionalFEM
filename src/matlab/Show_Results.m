function [factor_Lin, factor_Cub] = ...
    Show_Results(numElements, solutionSize, ...
    x, uExact, uFEMLin, uFEMCub, relTol)

%SHOW_RESULTS Plot FEM results and compute convergence summaries.

% Plot exact and FEM-Solution of the problem for different element numbers:
Plot_FEM_Solutions(numElements, solutionSize, x, uExact, uFEMLin, uFEMCub);

% Estimate squared errors and convergence factors:
[factor_Lin, factor_Cub] = ...
    Estimate_Error(numElements, uExact, uFEMLin, uFEMCub, relTol);

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
