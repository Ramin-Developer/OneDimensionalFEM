function tests = test_sparse_assembly
%TEST_SPARSE_ASSEMBLY Verify sparse global matrix storage and scaling.

tests = functiontests(localfunctions);
end

function testGlobalMatricesUseLinearSparseStorage(~)
numElements = 128;
meshSize = 1 / numElements;
qFunc = @(x) 1 + x;
loadFunc = @(x) 1 + 2 .* x - 3 .* x.^2;

[~, ~, stats] = Calc_FEM_Sol( ...
    numElements, meshSize, 0, 0.01, qFunc, loadFunc, 1e-10);

assert(stats.linear_Is_Sparse && stats.cubic_Is_Sparse, ...
    'Both global stiffness matrices must use sparse storage.');
assert(stats.linear_Nnz <= 3 * numElements + 1, ...
    'Linear matrix nonzeros must scale linearly with element count.');
assert(stats.cubic_Nnz <= 12 * numElements + 4, ...
    'Cubic matrix nonzeros must scale linearly with element count.');
assert(stats.linear_Storage_Bytes < 0.2 * stats.linear_Dense_Bytes, ...
    'Linear sparse storage must be substantially smaller than dense storage.');
assert(stats.cubic_Storage_Bytes < 0.2 * stats.cubic_Dense_Bytes, ...
    'Cubic sparse storage must be substantially smaller than dense storage.');
end