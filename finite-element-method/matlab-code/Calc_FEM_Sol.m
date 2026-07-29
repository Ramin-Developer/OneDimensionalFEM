function [u_FEM_Lin, u_FEM_Cub] = Calc_FEM_Sol( N, h, ...
    delta, P, q_Func, load_Func, RelTol )

%CALC_FEM_SOL Solve linear and cubic FEM approximations on one mesh.

% Define local and global basis functions and their first derivative:
[psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub] = Def_FEM_Func;

% Setup and solve the Eq. system for yhe unknown coefficients:
[a_Lin, a_Cub] = ...
    Solve_Eq_Sys( N, h, delta, P, q_Func, load_Func, ...
    psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub, RelTol );

% Construct FEM-Solution as a linear combination of basis-functions:
u_FEM_Lin = Build_Local_Solution(1, N, a_Lin, psi_Lin);
u_FEM_Cub = Build_Local_Solution(3, N, a_Cub, psi_Cub);

function u_FEM = Build_Local_Solution(degree, N, a, psi)

u_FEM = cell( N, 1 );

% Construct Linear-FEM solution:
if degree == 1
    for e = 1:1:N
        u_FEM{ e } = @(y) a(e) * psi{ 1 }( y ) ...
            + a(e + 1) * psi{ 2 }( y );
    end;
    return;
end;

% Construct Cubic-FEM solution:
for e = 1:1:N
    u_FEM{ e } = @(y) a(e) * psi{ 1 }( y ) ...
        + a(e + 1) * psi{ 2 }( y ) ...
        + a(e + N + 1) * psi{ 3 }( y ) ...
        + a(e + N + 2) * psi{ 4 }( y );
end;
