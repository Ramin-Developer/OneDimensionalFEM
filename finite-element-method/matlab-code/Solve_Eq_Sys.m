function [sysSolLin, sysSolCub] = ...
     Solve_Eq_Sys( N, h, delta, P, q_Func, load_Func, ...
    psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub, RelTol )

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

    for i = n:1:n + 1
        for j = n:1:n + 1
            
            % Linear assembly:
            K_Lin(i, j) = K_Lin(i, j) + K_Elem_Lin(i - n + 1, j - n + 1);
            
            % Cubic assembly:
            K_Cub(i, j) = K_Cub(i, j) + K_Elem_Cub(i - n + 1, j - n + 1);
            K_Cub(i, j + N + 1) = K_Cub(i, j + N + 1) ...
                + K_Elem_Cub(i - n + 1, j - n + 3);
            K_Cub(i + N + 1, j) = K_Cub(i + N + 1, j) ...
                + K_Elem_Cub(i - n + 3, j - n + 1);
            K_Cub(i + N + 1, j + N + 1) = K_Cub(i + N + 1, j + N + 1) ...
                + K_Elem_Cub(i - n + 3, j - n + 3);
            
        end;
	 
        % Linear load assembly:
        b_Lin(i) = b_Lin(i) + b_Elem_Lin(i - n + 1);

        % Cubic load assembly:
        b_Cub(i) = b_Cub(i) + b_Elem_Cub(i - n + 1);
        b_Cub(i + N + 1) = b_Cub(i + N + 1) + b_Elem_Cub(i - n + 3);
        
    end;    
end;

% Implement boundary conditions for the linear-FEM:
sysSolLin = Bound_Cond(1, N, h, delta, P, q_Func, K_Lin, b_Lin);

% Implement boundary conditions for the cubic-FEM:
sysSolCub = Bound_Cond(3, N, h, delta, P, q_Func, K_Cub, b_Cub);

function sysSol = Bound_Cond(basis_Degree, N, h, delta, P, q_Func, K, b)

% Based on the valur of basis_Degree, this function implements boundary
% conditions in the linear and cubbic cases.

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
