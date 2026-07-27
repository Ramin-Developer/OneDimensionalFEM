
clc;
clear;
close('all');

% Read input parameters:
[q_Type, q_Coeff, load_Coeff, delta, P, no_Of_Elements] = Read_input;

% Define variables and functions of the problem:
[h, sol_Size, q_Func, load_Func, ...
    x, u_FEM_Lin, u_FEM_Cub, u_Exact, RelTol] = ...
    Def_Problem( no_Of_Elements, q_Type, load_Coeff, q_Coeff, delta, P);

% Calculate FEM solution:
for size_Ind = 1:1:length(no_Of_Elements)
    [u_FEM_Lin{ size_Ind }, u_FEM_Cub{ size_Ind } ] = ...
        Calc_FEM_Sol( no_Of_Elements( size_Ind ), h( size_Ind ), ...
        delta, P, q_Func, load_Func, RelTol );
end


% Error estimation:
[conv_Factor, sq_Error] = ...
    Show_Results(no_Of_Elements, sol_Size, x, ...
    u_Exact, u_FEM_Lin, u_FEM_Cub, RelTol);
