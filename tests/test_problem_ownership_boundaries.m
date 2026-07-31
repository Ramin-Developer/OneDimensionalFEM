function tests = test_problem_ownership_boundaries
%TEST_PROBLEM_OWNERSHIP_BOUNDARIES Verify Def_Problem delegates validation.

tests = functiontests(localfunctions);
end

function testDefProblemPropagatesInvalidQType(testCase)
verifyError(testCase, @() Def_Problem([4 8], 12, [1 2 -3], [1], 0, 0), ...
    'Def_Problem:InvalidQType');
end

function testDefProblemPropagatesInvalidBoundaryData(testCase)
verifyError(testCase, @() Def_Problem([4 8], 'q_const', [1 2 -3], [1], NaN, 0), ...
    'Def_Problem:InvalidBoundaryData');
end

function testDefProblemReturnsExpectedSizes(~)
[meshSize, solutionSize, ~, ~, x, uLin, uCub, uExact, relTol] = ...
    Def_Problem([4 8], 'q_const', [1 2 -3], [1], 0, 0.01);

assert(isequal(size(meshSize), [1 2]));
assert(solutionSize == 2^10);
assert(numel(x) == solutionSize + 1);
assert(iscell(uLin) && numel(uLin) == 2);
assert(iscell(uCub) && numel(uCub) == 2);
assert(isa(uExact, 'function_handle'));
assert(relTol == 1e-12);
end