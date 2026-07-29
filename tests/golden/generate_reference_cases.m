function generate_reference_cases()
%GENERATE_REFERENCE_CASES Generate deterministic reference snapshots by N.

addpath(genpath('src/matlab'));

[qType, qCoeff, loadCoeff, delta, P, ~] = Read_input;
selectedNumElements = [4 8 16];
sampleX = linspace(0, 1, 9)';

tol = struct;
tol.fieldAbs = 5e-10;
tol.errorAbs = 5e-10;
tol.convAbs = 5e-8;

for idx = 1:numel(selectedNumElements)
    numElements = selectedNumElements(idx);
    femData = Compute_FEM_Data(numElements, qType, qCoeff, loadCoeff, delta, P);

    referenceCase = struct;
    referenceCase.qType = qType;
    referenceCase.qCoeff = qCoeff;
    referenceCase.loadCoeff = loadCoeff;
    referenceCase.delta = delta;
    referenceCase.P = P;
    referenceCase.numElements = numElements;
    referenceCase.sampleX = sampleX;
    referenceCase.exactVals = femData.u_Exact(sampleX);
    referenceCase.linVals = EvaluateFieldsAtSamples(femData.u_FEM_Lin{1}, numElements, sampleX);
    referenceCase.cubVals = EvaluateFieldsAtSamples(femData.u_FEM_Cub{1}, numElements, sampleX);
    referenceCase.sqErrorLin = femData.sq_Error_Lin;
    referenceCase.sqErrorCub = femData.sq_Error_Cub;

    assert(isstruct(referenceCase) && isstruct(tol), ...
        'generate_reference_cases:InvalidSnapshotData', ...
        'Reference snapshot payload must be struct data.');

    outputPath = sprintf('tests/golden/reference_qconst_N%d.mat', numElements);
    save(outputPath, 'referenceCase', 'tol');
end

function values = EvaluateFieldsAtSamples(localFields, numElements, sampleX)

values = zeros(numel(sampleX), 1);
h = 1 / numElements;

for sampleIdx = 1:numel(sampleX)
    xVal = sampleX(sampleIdx);
    elemNo = min(max(floor(xVal / h) + 1, 1), numElements);

    % Use left element at boundaries to keep evaluation deterministic.
    if elemNo > 1 && abs(xVal - (elemNo - 1) * h) < 1e-14
        elemNo = elemNo - 1;
    end

    y = (xVal - (elemNo - 1) * h) / h;
    values(sampleIdx) = localFields{elemNo}(y);
end