function tests = test_element_assembly
%TEST_ELEMENT_ASSEMBLY Verify basic element matrix/vector consistency.

tests = functiontests(localfunctions);
end

function testElementSymmetryAndSizes(~)
[psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub] = Def_FEM_Func;

h = 0.25;
elem_No = 2;
q_Func = @(x) 1 + 0.*x;
load_Func = @(x) 1 + x;
relTol = 1e-10;

[K_Lin, b_Lin, K_Cub, b_Cub] = Elem_Cont( ...
    h, elem_No, q_Func, load_Func, ...
    psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub, relTol);

assert(isequal(size(K_Lin), [2 2]));
assert(isequal(size(b_Lin), [2 1]));
assert(isequal(size(K_Cub), [4 4]));
assert(isequal(size(b_Cub), [4 1]));

assert(norm(K_Lin - K_Lin.', inf) < 1e-12, 'Linear element matrix not symmetric.');
assert(norm(K_Cub - K_Cub.', inf) < 1e-12, 'Cubic element matrix not symmetric.');
end

function testElementEnergyNonNegative(~)
[psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub] = Def_FEM_Func;

h = 0.2;
q_Func = @(x) 2 + x;
load_Func = @(x) 0.*x;
relTol = 1e-10;

[K_Lin, ~, K_Cub, ~] = Elem_Cont( ...
    h, 1, q_Func, load_Func, ...
    psi_Lin, psi_Prime_Lin, psi_Cub, psi_Prime_Cub, relTol);

rng(1);
vLin = randn(2,1);
vCub = randn(4,1);

energyLin = vLin.' * K_Lin * vLin;
energyCub = vCub.' * K_Cub * vCub;

assert(energyLin > -1e-10, 'Linear element matrix violates non-negative energy check.');
assert(energyCub > -1e-10, 'Cubic element matrix violates non-negative energy check.');
end

function testRejectsInvalidFunctions(testCase)
verifyError(testCase, @() Elem_Cont(0.5, 1, 1, @(x) x, ...
    { @(x) x }, { @(x) x }, { @(x) x }, { @(x) x }, 1e-8), ...
    'Elem_Cont:InvalidFunctions');
end
