function [psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub] = Def_FEM_Func

[psi_Lin, psi_Prime_Lin] = Def_Linear_FEM;
[psi_Cub, psi_Prime_Cub] = Def_Cubic_FEM;

function [psi_Lin, psi_Prime_Lin] = Def_Linear_FEM

% Linear shape functions, in local coordinates:
psi_Lin = cell( 2, 1 );
psi_Lin{1} = @(y) 1 - y;
psi_Lin{2} = @(y) y;

% Derivative of lineat shape functions in the local coordinates:
psi_Prime_Lin = cell( 2, 1);
psi_Prime_Lin{1} = @(y) -1;
psi_Prime_Lin{2} = @(y) 1;

function [psi_Cub, psi_Prime_Cub] = Def_Cubic_FEM

% Cubic shape functions, in local coordinates:
psi_Cub = cell(4, 1);
psi_Cub{1} = @(y) 1 - 3*y.^2 + 2*y.^3;
psi_Cub{2} = @(y) 3*y.^2 - 2*y.^3;
psi_Cub{3} = @(y) y -2*y.^2 + y.^3;
psi_Cub{4} = @(y) -y.^2 + y.^3;

% Derivative of cubic shape functions in the local coordinates:
psi_Prime_Cub = cell(4, 1);
psi_Prime_Cub{1} = @(y) -6*y + 6*y.^2;
psi_Prime_Cub{2} = @(y) 6*y -6*y.^2;
psi_Prime_Cub{3} = @(y) 1 - 4*y + 3*y.^2;
psi_Prime_Cub{4} = @(y) -2*y + 3*y.^2;
