function [uFEMLin, uFEMCub] = Calc_FEM_Sol(numElements, meshSize, ...
    delta, P, qFunc, loadFunc, relTol)

%CALC_FEM_SOL Solve linear and cubic FEM approximations on one mesh.

% Define local and global basis functions and their first derivative:
[psiLin, psiPrimeLin, psiCub, psiPrimeCub] = Def_FEM_Func;

% Setup and solve the equation system for the unknown coefficients:
[aLin, aCub] = ...
    Solve_Eq_Sys(numElements, meshSize, delta, P, qFunc, loadFunc, ...
    psiLin, psiPrimeLin, psiCub, psiPrimeCub, relTol);

% Construct FEM-Solution as a linear combination of basis-functions:
uFEMLin = Build_Local_Solution(1, numElements, aLin, psiLin);
uFEMCub = Build_Local_Solution(3, numElements, aCub, psiCub);

function uFEM = Build_Local_Solution(degree, numElements, a, psi)

uFEM = cell(numElements, 1);

% Construct Linear-FEM solution:
if degree == 1
    for elemNo = 1:1:numElements
        uFEM{elemNo} = @(y) a(elemNo) * psi{1}(y) ...
            + a(elemNo + 1) * psi{2}(y);
    end;
    return;
end;

% Construct Cubic-FEM solution:
for elemNo = 1:1:numElements
    uFEM{elemNo} = @(y) a(elemNo) * psi{1}(y) ...
        + a(elemNo + 1) * psi{2}(y) ...
        + a(elemNo + numElements + 1) * psi{3}(y) ...
        + a(elemNo + numElements + 2) * psi{4}(y);
end;
