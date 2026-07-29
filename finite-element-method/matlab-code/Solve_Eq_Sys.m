function [sysSolLin, sysSolCub] = ...
     Solve_Eq_Sys( N, h, delta, P, q_Func, load_Func, ...
    psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub, RelTol )

%SOLVE_EQ_SYS Assemble and solve linear/cubic FEM systems.

K_Lin = zeros(N + 1, N + 1);
b_Lin = zeros(N + 1, 1);
K_Cub = zeros(2*N + 2, 2*N + 2);
b_Cub = zeros(2*N + 2, 1);

% Build up the global stiffness matrix and load vector:
for n = 1:1:N

    % Construct element stiffness matrix and element load vector:
    [K_Elem_Lin, b_Elem_Lin, K_Elem_Cub, b_Elem_Cub] = ...
        Elem_Cont( h, n, q_Func, load_Func, ...
        psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub, RelTol );

    idx_Lin = n:n + 1;
    K_Lin(idx_Lin, idx_Lin) = K_Lin(idx_Lin, idx_Lin) + K_Elem_Lin;
    b_Lin(idx_Lin) = b_Lin(idx_Lin) + b_Elem_Lin;

    idx_Cub_Node = n:n + 1;
    idx_Cub_Slope = idx_Cub_Node + N + 1;
    idx_Cub = [idx_Cub_Node idx_Cub_Slope];
    K_Cub(idx_Cub, idx_Cub) = K_Cub(idx_Cub, idx_Cub) + K_Elem_Cub;
    b_Cub(idx_Cub) = b_Cub(idx_Cub) + b_Elem_Cub;
end;

% Implement boundary conditions for the linear-FEM:
sysSolLin = Bound_Cond(1, N, h, delta, P, q_Func, K_Lin, b_Lin);

% Implement boundary conditions for the cubic-FEM:
sysSolCub = Bound_Cond(3, N, h, delta, P, q_Func, K_Cub, b_Cub);

function sysSol = Bound_Cond(basis_Degree, N, h, delta, P, q_Func, K, b)

% Apply boundary conditions for linear and cubic systems.

if basis_Degree == 1
    dim = N + 1;

    % Adjusting load value on the right boundary:
	b(dim) = P + b(dim);

else
    dim = 2*N + 2;
    % Adjusting load value on the right boundary:
    b(N + 1) = b(N + 1) + P;

    % Implement Normal Condition on the right boundary:
    K(dim, :) = zeros(1, dim);
    K(dim, dim) = 1;
    b(dim) = h * P / q_Func(1);
end;

% Implement Dirichlet Condition on the left boundary:
K(1, :) = zeros(1, dim);
K(1, 1) = 1;
b( 1 ) = delta;

sysSol = K\b;
sysSol(1) = delta;
