% MAIN_PROGRAM Run 1D FEM solver and post-processing.
%
% This file remains script-compatible for MATLAB R2017a while delegating
% core steps to local functions for clearer structure.

clc;
clear;
close('all');

% Read and validate model configuration.
[q_Type, q_Coeff, load_Coeff, delta, P, numElements] = Read_input;
Validate_Input(q_Type, q_Coeff, load_Coeff, delta, P, numElements);

% Compute FEM data with no plotting side effects.
fem_Data = Compute_FEM_Data( ...
    numElements, q_Type, q_Coeff, load_Coeff, delta, P);

% Error estimation and plotting.
[resultTextLin, resultTextCub] = ...
    Show_Results(fem_Data.num_Elements, fem_Data.solution_Size, fem_Data.x, ...
    fem_Data.u_Exact, fem_Data.u_FEM_Lin, fem_Data.u_FEM_Cub, fem_Data.rel_Tol);
