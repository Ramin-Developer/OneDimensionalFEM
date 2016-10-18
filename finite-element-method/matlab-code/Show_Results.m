function [factor_Lin, factor_Cub] = ...
    Show_Results(no_Of_Elements, sol_Size, ...
    x, u_Exact, u_FEM_Lin, u_FEM_Cub, RelTol)

% Plot exact and FEM-Solution of the problem for different element numbers:
Plot_Solutions(no_Of_Elements, sol_Size, ...
    x, u_Exact, u_FEM_Lin, u_FEM_Cub);

% Estimate squared errors and convergence factors: 
[factor_Lin, factor_Cub] = ...
    Estimate_Error(no_Of_Elements, u_Exact, u_FEM_Lin, u_FEM_Cub, RelTol);


function Plot_Solutions(no_Of_Elements, sol_Size, ...
    x, u_Exact, u_FEM_Lin, u_FEM_Cub)

% Element size in the FEM solution
elem_Size = sol_Size ./ no_Of_Elements;

% Construct exact solution:
sol_Exact = u_Exact(x);
size_N = length( no_Of_Elements );

% Construct a three dimensional matrix for the FEM-solution of the problem.
% Element (i, j, 1) is the Linear-FEM Solution at x_i with j elements.
% Element (i, j, 2) is the Cubic-FEM Solution at x_i with j elements.
u_FEM = zeros( sol_Size + 1, size_N, 2 );

% Construct FEM-Solution as a linear combination of the shape-functions:
for size_Ind = 1:1:size_N
    
    N = no_Of_Elements( size_Ind );
	y = linspace( 0, 1, elem_Size( size_Ind ) + 1 )';
    for elem_No = 1:1:N
        
        start = (elem_No - 1) * elem_Size( size_Ind ) + 1;
        last = start + elem_Size( size_Ind );
        
        % Linear Solution:
        u_FEM( start:last, size_Ind, 1) = ...
            u_FEM_Lin{ size_Ind }{ elem_No }( y );
        
        % Cubic Solution:
        u_FEM( start:last, size_Ind, 2) = ...
            u_FEM_Cub{ size_Ind }{ elem_No }( y );
    end;
end;

figure();
left = 0.09;
bottom = 0.55;
width = 0.24;
height = 0.40;
horizontalSpace = 0.08;

for k = 1:1:2
    for size_Ind = 1:1:min(size_N, 3)

        N = no_Of_Elements( size_Ind );
        subplot(2, size_N, (k - 1)*size_N + size_Ind, 'Position', ...
            [left bottom width height] );
        plot(x, sol_Exact , 'red', x, u_FEM(:, size_Ind, k), ...
            'green', 'LineWidth', 2);
        left = left + width + horizontalSpace;

        % Grid and thick marks:
        grid;
        set( gca, 'FontName', 'Arial', 'FontSize', 14 );
        set( gca, 'XTick', [0.25 0.5 0.75 1] );
                
        % Legend
        str_FEM = ['$u_{cub}$, ' 'N = ' num2str( N ) ];
        if k == 1
            str_FEM = ['$u_{lin}$, ' 'N = ' num2str( N ) ];
        end;
        h_leg = legend( '$u_{ex}$', str_FEM, ...
            'Location', 'Northwest', 'Orientation', 'Vertical' );
        set( h_leg, 'Interpreter', 'Latex', 'FontSize', 14 );
    end;
    
    left = 0.09;
    bottom = 0.05;
    width = 0.24;
    height = 0.40;
    horizontalSpace = 0.08;
end;

function [error_Lin, error_Cub] = ...
    Estimate_Error(no_Of_Elements, u_Exact, u_FEM_Lin, u_FEM_Cub, RelTol)

size_N = length( no_Of_Elements );
tot_Error = zeros(2, size_N );

for size_Ind = 1:1:size_N
    
    N = no_Of_Elements( size_Ind );
    h = 1 / N;
    for elem_No = 1:1:N
        
        global_Coord = @( y ) ( elem_No - 1 + y ) .* h;
        
        % Setup linear and cubic squared error functions:
        sq_Error_Lin = @( y ) ...
            ( u_Exact( global_Coord( y ) ) ...
            - u_FEM_Lin{ size_Ind }{ elem_No }( y ) ).^2;

        sq_Error_Cub = @( y ) ...
            ( u_Exact( global_Coord( y ) ) ...
            - u_FEM_Cub{ size_Ind }{ elem_No }( y ) ).^2;

        % Integrate the error functions to find linear and cubic errors:
        tot_Error( 1, size_Ind ) = tot_Error( 1, size_Ind ) + ...
            quadgk( sq_Error_Lin, 0, 1, 'RelTol', RelTol );
        
        tot_Error( 2, size_Ind ) = tot_Error( 2, size_Ind ) + ...
            quadgk( sq_Error_Cub, 0, 1, 'RelTol', RelTol );
    end;
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
