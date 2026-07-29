function tests = test_golden_snapshot_regression
%TEST_GOLDEN_SNAPSHOT_REGRESSION Deterministic baseline snapshot checks.

tests = functiontests(localfunctions);

function testBaselineSnapshotMatches(~)
addpath(genpath('src/matlab'));
addpath('tests/golden');
ensure_golden_snapshots();

data = load('tests/golden/baseline_qconst_snapshot.mat');
snapshot = data.snapshot;
tol = data.tol;

femData = Compute_FEM_Data( ...
    snapshot.numElements, snapshot.q_Type, snapshot.q_Coeff, ...
    snapshot.load_Coeff, snapshot.delta, snapshot.P);

sampleX = snapshot.sampleX;
linVals = EvaluateFieldsAtSamples(femData.u_FEM_Lin, snapshot.numElements, sampleX);
cubVals = EvaluateFieldsAtSamples(femData.u_FEM_Cub, snapshot.numElements, sampleX);
exactVals = femData.u_Exact(sampleX);

assert(max(abs(exactVals - snapshot.exactVals)) <= tol.fieldAbs, ...
    'Exact solution snapshot mismatch.');
assert(max(abs(linVals(:) - snapshot.linVals(:))) <= tol.fieldAbs, ...
    'Linear FEM field snapshot mismatch.');
assert(max(abs(cubVals(:) - snapshot.cubVals(:))) <= tol.fieldAbs, ...
    'Cubic FEM field snapshot mismatch.');
assert(max(abs(femData.sq_Error_Lin(:) - snapshot.sqErrorLin(:))) <= tol.errorAbs, ...
    'Linear error snapshot mismatch.');
assert(max(abs(femData.sq_Error_Cub(:) - snapshot.sqErrorCub(:))) <= tol.errorAbs, ...
    'Cubic error snapshot mismatch.');
assert(max(abs(femData.conv_Factor_Lin(:) - snapshot.convLin(:))) <= tol.convAbs, ...
    'Linear convergence snapshot mismatch.');
assert(max(abs(femData.conv_Factor_Cub(:) - snapshot.convCub(:))) <= tol.convAbs, ...
    'Cubic convergence snapshot mismatch.');

function values = EvaluateFieldsAtSamples(localFieldsByMesh, numElementsList, sampleX)

values = zeros(numel(sampleX), numel(numElementsList));

for meshIdx = 1:numel(numElementsList)
    numElements = numElementsList(meshIdx);
    h = 1 / numElements;

    for sampleIdx = 1:numel(sampleX)
        xVal = sampleX(sampleIdx);
        elemNo = min(max(floor(xVal / h) + 1, 1), numElements);

        % Map element-boundary points consistently to the left element.
        if elemNo > 1 && abs(xVal - (elemNo - 1) * h) < 1e-14
            elemNo = elemNo - 1;
        end

        y = (xVal - (elemNo - 1) * h) / h;
        values(sampleIdx, meshIdx) = localFieldsByMesh{meshIdx}{elemNo}(y);
    end
end
