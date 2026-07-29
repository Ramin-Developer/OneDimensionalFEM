function ensure_golden_snapshots()
%ENSURE_GOLDEN_SNAPSHOTS Ensure required golden MAT files exist.

goldenDir = fileparts(mfilename('fullpath'));
testsDir = fileparts(goldenDir);
repoRoot = fileparts(testsDir);

requiredFiles = { ...
    fullfile(goldenDir, 'baseline_qconst_snapshot.mat'), ...
    fullfile(goldenDir, 'reference_qconst_N4.mat'), ...
    fullfile(goldenDir, 'reference_qconst_N8.mat'), ...
    fullfile(goldenDir, 'reference_qconst_N16.mat') ...
};

isMissing = false;
for idx = 1:numel(requiredFiles)
    if exist(requiredFiles{idx}, 'file') ~= 2
        isMissing = true;
        break;
    end
end

if ~isMissing
    return;
end

% Rebuild all deterministic snapshot artifacts from current baseline setup.
generate_baseline_snapshot();
generate_reference_cases();

function generate_baseline_snapshot()

goldenDir = fileparts(mfilename('fullpath'));
testsDir = fileparts(goldenDir);
repoRoot = fileparts(testsDir);

addpath(genpath(fullfile(repoRoot, 'src', 'matlab')));
[q_Type, q_Coeff, load_Coeff, delta, P, numElements] = Read_input;
femData = Compute_FEM_Data(numElements, q_Type, q_Coeff, load_Coeff, delta, P);

sampleX = [0; 0.25; 0.5; 0.75; 1.0];
linVals = EvaluateFieldsByMesh(femData.u_FEM_Lin, numElements, sampleX);
cubVals = EvaluateFieldsByMesh(femData.u_FEM_Cub, numElements, sampleX);

snapshot = struct;
snapshot.q_Type = q_Type;
snapshot.q_Coeff = q_Coeff;
snapshot.load_Coeff = load_Coeff;
snapshot.delta = delta;
snapshot.P = P;
snapshot.numElements = numElements;
snapshot.sampleX = sampleX;
snapshot.exactVals = femData.u_Exact(sampleX);
snapshot.linVals = linVals;
snapshot.cubVals = cubVals;
snapshot.sqErrorLin = femData.sq_Error_Lin;
snapshot.sqErrorCub = femData.sq_Error_Cub;
snapshot.convLin = femData.conv_Factor_Lin;
snapshot.convCub = femData.conv_Factor_Cub;

tol = struct;
tol.fieldAbs = 5e-10;
tol.errorAbs = 5e-10;
tol.convAbs = 5e-8;

save(fullfile(goldenDir, 'baseline_qconst_snapshot.mat'), 'snapshot', 'tol');

function values = EvaluateFieldsByMesh(localFieldsByMesh, numElementsList, sampleX)

values = zeros(numel(sampleX), numel(numElementsList));

for meshIdx = 1:numel(numElementsList)
    numElements = numElementsList(meshIdx);
    h = 1 / numElements;
    localFields = localFieldsByMesh{meshIdx};

    for sampleIdx = 1:numel(sampleX)
        xVal = sampleX(sampleIdx);
        elemNo = min(max(floor(xVal / h) + 1, 1), numElements);
        if elemNo > 1 && abs(xVal - (elemNo - 1) * h) < 1e-14
            elemNo = elemNo - 1;
        end
        y = (xVal - (elemNo - 1) * h) / h;
        values(sampleIdx, meshIdx) = localFields{elemNo}(y);
    end
end