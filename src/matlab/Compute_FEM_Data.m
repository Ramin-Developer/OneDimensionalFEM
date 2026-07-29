function fem_Data = Compute_FEM_Data(numElements, q_Type, q_Coeff, load_Coeff, delta, P)
%COMPUTE_FEM_DATA Compute FEM solutions and error metrics without plotting.
%
%   fem_Data = COMPUTE_FEM_DATA(numElements, q_Type, q_Coeff, ...
%       load_Coeff, delta, P) returns a struct with mesh parameters,
%   exact solution, local FEM fields, and L2-style error summaries.

% Define problem data and allocate per-mesh solution containers.
[meshSize, solutionSize, qFunc, loadFunc, x, ...
    uFEMLin, uFEMCub, uExact, relTol] = ...
    Def_Problem(numElements, q_Type, load_Coeff, q_Coeff, delta, P);

for idx = 1:numel(numElements)
    [uFEMLin{idx}, uFEMCub{idx}] = Calc_FEM_Sol( ...
        numElements(idx), meshSize(idx), delta, P, qFunc, loadFunc, relTol);
end

[sq_Error_Lin, sq_Error_Cub, conv_Factor_Lin, conv_Factor_Cub] = ...
    Compute_Error_Summary(numElements, uExact, uFEMLin, uFEMCub, relTol);

fem_Data = struct( ...
    'num_Elements', numElements, ...
    'mesh_Size', meshSize, ...
    'solution_Size', solutionSize, ...
    'x', x, ...
    'u_Exact', uExact, ...
    'u_FEM_Lin', {uFEMLin}, ...
    'u_FEM_Cub', {uFEMCub}, ...
    'rel_Tol', relTol, ...
    'sq_Error_Lin', sq_Error_Lin, ...
    'sq_Error_Cub', sq_Error_Cub, ...
    'conv_Factor_Lin', conv_Factor_Lin, ...
    'conv_Factor_Cub', conv_Factor_Cub);

function [sq_Error_Lin, sq_Error_Cub, conv_Factor_Lin, conv_Factor_Cub] = ...
    Compute_Error_Summary(no_Of_Elements, u_Exact, u_FEM_Lin, u_FEM_Cub, relTol)

size_N = length(no_Of_Elements);
tot_Error = zeros(2, size_N);

for size_Ind = 1:1:size_N
    N = no_Of_Elements(size_Ind);
    tot_Error(1, size_Ind) = Integrate_Squared_Error( ...
        u_Exact, u_FEM_Lin{size_Ind}, N, relTol);
    tot_Error(2, size_Ind) = Integrate_Squared_Error( ...
        u_Exact, u_FEM_Cub{size_Ind}, N, relTol);
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

function sq_Error = Integrate_Squared_Error(u_Exact, local_Fields, N, relTol)

h = 1 / N;
sq_Error = 0;

for elem_No = 1:N
    global_Coord = @(y) (elem_No - 1 + y) .* h;
    sq_Error_Local = @(y) ...
        (u_Exact(global_Coord(y)) - local_Fields{elem_No}(y)).^2;
    sq_Error = sq_Error + quadgk(sq_Error_Local, 0, 1, 'RelTol', relTol);
end