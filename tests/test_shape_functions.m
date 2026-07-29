function tests = test_shape_functions
%TEST_SHAPE_FUNCTIONS Verify linear/cubic shape function identities.

tests = functiontests(localfunctions);

function testLinearPartitionOfUnity(~)
[psi_Lin, ~, ~, ~] = Def_FEM_Func;
y = linspace(0, 1, 101)';
residual = psi_Lin{1}(y) + psi_Lin{2}(y) - 1;
assert(max(abs(residual)) < 1e-12, 'Linear partition of unity failed.');

function testCubicNodalValues(~)
[~, ~, psi_Cub, psi_Prime_Cub] = Def_FEM_Func;

assert(abs(psi_Cub{1}(0) - 1) < 1e-12);
assert(abs(psi_Cub{1}(1) - 0) < 1e-12);
assert(abs(psi_Cub{2}(0) - 0) < 1e-12);
assert(abs(psi_Cub{2}(1) - 1) < 1e-12);

assert(abs(psi_Cub{3}(0) - 0) < 1e-12);
assert(abs(psi_Cub{3}(1) - 0) < 1e-12);
assert(abs(psi_Cub{4}(0) - 0) < 1e-12);
assert(abs(psi_Cub{4}(1) - 0) < 1e-12);

assert(abs(psi_Prime_Cub{3}(0) - 1) < 1e-12);
assert(abs(psi_Prime_Cub{3}(1) - 0) < 1e-12);
assert(abs(psi_Prime_Cub{4}(0) - 0) < 1e-12);
assert(abs(psi_Prime_Cub{4}(1) - 1) < 1e-12);

function testCubicValuePartition(~)
[~, ~, psi_Cub, ~] = Def_FEM_Func;
y = linspace(0, 1, 101)';
residual = psi_Cub{1}(y) + psi_Cub{2}(y) - 1;
assert(max(abs(residual)) < 1e-12, 'Cubic value-function partition failed.');
