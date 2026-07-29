% MAIN_PROGRAM Run 1D FEM solver and post-processing.
%
% This file remains script-compatible for MATLAB R2017a while delegating
% core steps to local functions for clearer structure.

clc;
clear;
close('all');

% Read and validate model configuration.
[q_Type, q_Coeff, load_Coeff, delta, P, num_Elements] = Read_input;
Validate_Input(q_Type, q_Coeff, load_Coeff, delta, P, num_Elements);

% Define problem data and solve for each mesh size.
[mesh_Size, solution_Size, q_Func, load_Func, ...
    x, u_FEM_Lin, u_FEM_Cub, u_Exact, rel_Tol] = ...
    Def_Problem(num_Elements, q_Type, load_Coeff, q_Coeff, delta, P);

[u_FEM_Lin, u_FEM_Cub] = Run_FEM_Cases(num_Elements, mesh_Size, ...
    delta, P, q_Func, load_Func, rel_Tol, u_FEM_Lin, u_FEM_Cub);

% Error estimation and plotting.
[conv_Factor, sq_Error] = ...
    Show_Results(num_Elements, solution_Size, x, ...
    u_Exact, u_FEM_Lin, u_FEM_Cub, rel_Tol);

function [u_FEM_Lin, u_FEM_Cub] = Run_FEM_Cases(num_Elements, mesh_Size, ...
    delta, P, q_Func, load_Func, rel_Tol, u_FEM_Lin, u_FEM_Cub)

for idx = 1:numel(num_Elements)
    [u_FEM_Lin{idx}, u_FEM_Cub{idx}] = Calc_FEM_Sol( ...
        num_Elements(idx), mesh_Size(idx), delta, P, ...
        q_Func, load_Func, rel_Tol);
end
