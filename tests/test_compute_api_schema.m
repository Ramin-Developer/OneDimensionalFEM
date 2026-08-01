function tests = test_compute_api_schema
%TEST_COMPUTE_API_SCHEMA Guard the public Compute_FEM_Data output contract.

tests = functiontests(localfunctions);
end

function testComputeApiSchemaV1(~)
numElements = [4 8 16];
qType = 'q_Const';
qCoeff = 1;
loadCoeff = [1 2 -3];
delta = 0;
P = 0.01;

femData = Compute_FEM_Data(numElements, qType, qCoeff, loadCoeff, delta, P);

expectedFields = {
    'num_Elements'
    'mesh_Size'
    'q_Type'
    'solution_Size'
    'x'
    'u_Exact'
    'u_FEM_Lin'
    'u_FEM_Cub'
    'rel_Tol'
    'l2_Error_Lin'
    'l2_Error_Cub'
    'convergence_Factor_Lin'
    'convergence_Factor_Cub'
    'convergence_Order_Lin'
    'convergence_Order_Cub'
};

actualFields = fieldnames(femData);
assert(isequal(actualFields, expectedFields), ...
    'Compute API schema mismatch: field names or ordering changed.');

n = numel(numElements);
assert(isnumeric(femData.num_Elements) && isequal(size(femData.num_Elements), size(numElements)), ...
    'num_Elements must preserve requested mesh vector shape.');
assert(isnumeric(femData.mesh_Size) && isvector(femData.mesh_Size) && numel(femData.mesh_Size) == n, ...
    'mesh_Size must align with num_Elements count.');
assert(ischar(femData.q_Type) && ~isempty(femData.q_Type), ...
    'q_Type must be a non-empty normalized char identifier.');
assert(isnumeric(femData.solution_Size) && isscalar(femData.solution_Size) ...
    && isfinite(femData.solution_Size) && femData.solution_Size > 0 ...
    && mod(femData.solution_Size, 1) == 0, ...
    'solution_Size must be a finite positive integer scalar.');
assert(isnumeric(femData.x) && isvector(femData.x), ...
    'x must be a numeric coordinate vector.');
assert(isa(femData.u_Exact, 'function_handle'), ...
    'u_Exact must be a function handle.');
assert(iscell(femData.u_FEM_Lin) && numel(femData.u_FEM_Lin) == n, ...
    'u_FEM_Lin must be a cell array with one entry per mesh.');
assert(iscell(femData.u_FEM_Cub) && numel(femData.u_FEM_Cub) == n, ...
    'u_FEM_Cub must be a cell array with one entry per mesh.');
assert(isnumeric(femData.rel_Tol) && isscalar(femData.rel_Tol) && isfinite(femData.rel_Tol) && femData.rel_Tol > 0, ...
    'rel_Tol must be a finite positive scalar.');

assert(isnumeric(femData.l2_Error_Lin) && isvector(femData.l2_Error_Lin) && numel(femData.l2_Error_Lin) == n, ...
    'l2_Error_Lin must provide one value per mesh.');
assert(isnumeric(femData.l2_Error_Cub) && isvector(femData.l2_Error_Cub) && numel(femData.l2_Error_Cub) == n, ...
    'l2_Error_Cub must provide one value per mesh.');
assert(all(isfinite(femData.l2_Error_Lin)) && all(femData.l2_Error_Lin >= 0), ...
    'l2_Error_Lin values must be finite and non-negative.');
assert(all(isfinite(femData.l2_Error_Cub)) && all(femData.l2_Error_Cub >= 0), ...
    'l2_Error_Cub values must be finite and non-negative.');

pairCount = max(n - 1, 0);
assert(isnumeric(femData.convergence_Factor_Lin) && numel(femData.convergence_Factor_Lin) == pairCount, ...
    'convergence_Factor_Lin must have one value per adjacent mesh pair.');
assert(isnumeric(femData.convergence_Factor_Cub) && numel(femData.convergence_Factor_Cub) == pairCount, ...
    'convergence_Factor_Cub must have one value per adjacent mesh pair.');
assert(isnumeric(femData.convergence_Order_Lin) && numel(femData.convergence_Order_Lin) == pairCount, ...
    'convergence_Order_Lin must have one value per adjacent mesh pair.');
assert(isnumeric(femData.convergence_Order_Cub) && numel(femData.convergence_Order_Cub) == pairCount, ...
    'convergence_Order_Cub must have one value per adjacent mesh pair.');

assert(all(isfinite(femData.convergence_Factor_Lin)), ...
    'convergence_Factor_Lin values must be finite.');
assert(all(isfinite(femData.convergence_Factor_Cub)), ...
    'convergence_Factor_Cub values must be finite.');
assert(all(isfinite(femData.convergence_Order_Lin)), ...
    'convergence_Order_Lin values must be finite.');
assert(all(isfinite(femData.convergence_Order_Cub)), ...
    'convergence_Order_Cub values must be finite.');
end
