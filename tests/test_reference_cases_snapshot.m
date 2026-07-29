function tests = test_reference_cases_snapshot
%TEST_REFERENCE_CASES_SNAPSHOT Verify per-mesh reference-case snapshots.

tests = functiontests(localfunctions);

function testReferenceCasesByN(testCase)
testDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(testDir);
addpath(genpath(fullfile(repoRoot, 'src', 'matlab')));
addpath(fullfile(testDir, 'golden'));
ensure_golden_snapshots();

selectedNumElements = [4 8 16];

for idx = 1:numel(selectedNumElements)
    numElements = selectedNumElements(idx);
    snapshotPath = fullfile(testDir, 'golden', sprintf('reference_qconst_N%d.mat', numElements));

    assert(exist(snapshotPath, 'file') == 2, ...
        'Missing reference snapshot file: %s', snapshotPath);

    data = load(snapshotPath);
    referenceCase = data.referenceCase;
    tol = data.tol;

    femData = Compute_FEM_Data( ...
        referenceCase.numElements, referenceCase.qType, referenceCase.qCoeff, ...
        referenceCase.loadCoeff, referenceCase.delta, referenceCase.P);

    linVals = EvaluateFieldsAtSamples( ...
        femData.u_FEM_Lin{1}, referenceCase.numElements, referenceCase.sampleX);
    cubVals = EvaluateFieldsAtSamples( ...
        femData.u_FEM_Cub{1}, referenceCase.numElements, referenceCase.sampleX);
    exactVals = femData.u_Exact(referenceCase.sampleX);

    verifyLessThanOrEqual(testCase, max(abs(exactVals - referenceCase.exactVals)), tol.fieldAbs);
    verifyLessThanOrEqual(testCase, max(abs(linVals - referenceCase.linVals)), tol.fieldAbs);
    verifyLessThanOrEqual(testCase, max(abs(cubVals - referenceCase.cubVals)), tol.fieldAbs);
    verifyLessThanOrEqual(testCase, max(abs(femData.sq_Error_Lin - referenceCase.sqErrorLin)), tol.errorAbs);
    verifyLessThanOrEqual(testCase, max(abs(femData.sq_Error_Cub - referenceCase.sqErrorCub)), tol.errorAbs);
end

function values = EvaluateFieldsAtSamples(localFields, numElements, sampleX)

values = zeros(numel(sampleX), 1);
h = 1 / numElements;

for sampleIdx = 1:numel(sampleX)
    xVal = sampleX(sampleIdx);
    elemNo = min(max(floor(xVal / h) + 1, 1), numElements);

    if elemNo > 1 && abs(xVal - (elemNo - 1) * h) < 1e-14
        elemNo = elemNo - 1;
    end

    y = (xVal - (elemNo - 1) * h) / h;
    values(sampleIdx) = localFields{elemNo}(y);
end