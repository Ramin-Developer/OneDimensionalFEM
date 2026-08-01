function tests = test_compute_api_contract_snapshot
%TEST_COMPUTE_API_CONTRACT_SNAPSHOT Verify Compute_FEM_Data against snapshot contract fixture.

tests = functiontests(localfunctions);
end

function testComputeApiContractSnapshot(~)
thisFile = mfilename('fullpath');
testsDir = fileparts(thisFile);
raw = fileread(fullfile(testsDir, 'golden', 'compute_api_contract_snapshot.json'));
snapshot = jsondecode(raw);

numElements = snapshot.scenario.numElements;
qType = char(snapshot.scenario.qType);
qCoeff = snapshot.scenario.qCoeff;
loadCoeff = snapshot.scenario.loadCoeff;
delta = snapshot.scenario.delta;
P = snapshot.scenario.P;

femData = Compute_FEM_Data(numElements, qType, qCoeff, loadCoeff, delta, P);

expectedFields = toCellstr(snapshot.contract.expectedFieldOrder);
assert(isequal(fieldnames(femData), expectedFields), ...
    'Compute API contract snapshot mismatch: field order or names changed.');

assert(strcmp(femData.q_Type, char(snapshot.contract.expectedQType)), ...
    'Compute API contract snapshot mismatch: normalized q_Type changed.');

meshCount = snapshot.contract.expectedMeshCount;
pairCount = snapshot.contract.expectedPairCount;

assert(numel(femData.num_Elements) == meshCount, ...
    'Compute API contract snapshot mismatch: num_Elements count changed.');
assert(numel(femData.mesh_Size) == meshCount, ...
    'Compute API contract snapshot mismatch: mesh_Size count changed.');
assert(isnumeric(femData.solution_Size) && isscalar(femData.solution_Size) ...
    && isfinite(femData.solution_Size) && femData.solution_Size > 0 ...
    && mod(femData.solution_Size, 1) == 0, ...
    'Compute API contract snapshot mismatch: solution_Size scalar contract changed.');
assert(numel(femData.u_FEM_Lin) == meshCount, ...
    'Compute API contract snapshot mismatch: u_FEM_Lin cell count changed.');
assert(numel(femData.u_FEM_Cub) == meshCount, ...
    'Compute API contract snapshot mismatch: u_FEM_Cub cell count changed.');

assert(numel(femData.l2_Error_Lin) == meshCount, ...
    'Compute API contract snapshot mismatch: l2_Error_Lin length changed.');
assert(numel(femData.l2_Error_Cub) == meshCount, ...
    'Compute API contract snapshot mismatch: l2_Error_Cub length changed.');
assert(numel(femData.convergence_Factor_Lin) == pairCount, ...
    'Compute API contract snapshot mismatch: convergence_Factor_Lin length changed.');
assert(numel(femData.convergence_Factor_Cub) == pairCount, ...
    'Compute API contract snapshot mismatch: convergence_Factor_Cub length changed.');
assert(numel(femData.convergence_Order_Lin) == pairCount, ...
    'Compute API contract snapshot mismatch: convergence_Order_Lin length changed.');
assert(numel(femData.convergence_Order_Cub) == pairCount, ...
    'Compute API contract snapshot mismatch: convergence_Order_Cub length changed.');

assert(isa(femData.u_Exact, 'function_handle'), ...
    'Compute API contract snapshot mismatch: u_Exact type changed.');
assert(isnumeric(femData.rel_Tol) && isscalar(femData.rel_Tol) && femData.rel_Tol > 0, ...
    'Compute API contract snapshot mismatch: rel_Tol shape/type changed.');

assert(abs(min(femData.x) - snapshot.contract.expectedXMin) < 1e-12, ...
    'Compute API contract snapshot mismatch: x minimum changed.');
assert(abs(max(femData.x) - snapshot.contract.expectedXMax) < 1e-12, ...
    'Compute API contract snapshot mismatch: x maximum changed.');

assert(all(isfinite(femData.l2_Error_Lin)) && all(femData.l2_Error_Lin >= 0), ...
    'Compute API contract snapshot mismatch: l2_Error_Lin finiteness/non-negativity changed.');
assert(all(isfinite(femData.l2_Error_Cub)) && all(femData.l2_Error_Cub >= 0), ...
    'Compute API contract snapshot mismatch: l2_Error_Cub finiteness/non-negativity changed.');
end

function values = toCellstr(inputValue)
if iscell(inputValue)
    values = inputValue;
elseif isstring(inputValue)
    values = cellstr(inputValue);
elseif ischar(inputValue)
    values = cellstr(inputValue);
else
    error('test_compute_api_contract_snapshot:InvalidSnapshot', ...
        'Unexpected expectedFieldOrder data type in snapshot.');
end
end
