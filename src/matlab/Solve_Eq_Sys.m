function [sysSolLin, sysSolCub] = ...
    Solve_Eq_Sys(numElements, meshSize, delta, P, qFunc, loadFunc, ...
    psiLin, psiPrimeLin, psiCub, psiPrimeCub, relTol)

%SOLVE_EQ_SYS Assemble and solve linear/cubic FEM systems.

K_Lin = zeros(numElements + 1, numElements + 1);
b_Lin = zeros(numElements + 1, 1);
K_Cub = zeros(2*numElements + 2, 2*numElements + 2);
b_Cub = zeros(2*numElements + 2, 1);

% Build up the global stiffness matrix and load vector:
for elemNo = 1:1:numElements

    % Construct element stiffness matrix and element load vector:
    [K_Elem_Lin, b_Elem_Lin, K_Elem_Cub, b_Elem_Cub] = ...
        Elem_Cont(meshSize, elemNo, qFunc, loadFunc, ...
        psiLin, psiPrimeLin, psiCub, psiPrimeCub, relTol);

    idx_Lin = elemNo:elemNo + 1;
    K_Lin(idx_Lin, idx_Lin) = K_Lin(idx_Lin, idx_Lin) + K_Elem_Lin;
    b_Lin(idx_Lin) = b_Lin(idx_Lin) + b_Elem_Lin;

    idx_Cub_Node = elemNo:elemNo + 1;
    idx_Cub_Slope = idx_Cub_Node + numElements + 1;
    idx_Cub = [idx_Cub_Node idx_Cub_Slope];
    K_Cub(idx_Cub, idx_Cub) = K_Cub(idx_Cub, idx_Cub) + K_Elem_Cub;
    b_Cub(idx_Cub) = b_Cub(idx_Cub) + b_Elem_Cub;
end;

% Implement boundary conditions for the linear-FEM:
sysSolLin = Bound_Cond(1, numElements, meshSize, delta, P, qFunc, K_Lin, b_Lin);

% Implement boundary conditions for the cubic-FEM:
sysSolCub = Bound_Cond(3, numElements, meshSize, delta, P, qFunc, K_Cub, b_Cub);

function sysSol = Bound_Cond(basisDegree, numElements, meshSize, delta, P, qFunc, K, b)

% Apply boundary conditions for linear and cubic systems.

if basisDegree == 1
    dim = numElements + 1;

    % Adjusting load value on the right boundary:
	b(dim) = P + b(dim);

else
    dim = 2*numElements + 2;
    % Adjusting load value on the right boundary:
    b(numElements + 1) = b(numElements + 1) + P;

    % Implement Normal Condition on the right boundary:
    K(dim, :) = zeros(1, dim);
    K(dim, dim) = 1;
    b(dim) = meshSize * P / qFunc(1);
end;

% Implement Dirichlet Condition on the left boundary:
K(1, :) = zeros(1, dim);
K(1, 1) = 1;
b( 1 ) = delta;

sysSol = K\b;
sysSol(1) = delta;
