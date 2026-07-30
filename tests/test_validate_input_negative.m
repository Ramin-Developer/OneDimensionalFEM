function tests = test_validate_input_negative
%TEST_VALIDATE_INPUT_NEGATIVE Validate expected failures for bad inputs.

tests = functiontests(localfunctions);

function testRejectsNonCharQType(testCase)
verifyError(testCase, @() Validate_Input(42, 1, [1 2 -3], 0, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidQType');

function testAcceptsNormalizedConstantAlias(testCase)
verifyWarningFree(testCase, @() Validate_Input('constant', 1, [1 2 -3], 0, 0.01, [4 8 16]));
end

function testAcceptsStringScalarQType(testCase)
verifyWarningFree(testCase, @() Validate_Input("constant", 1, [1 2 -3], 0, 0.01, [4 8 16]));
end

function testRejectsWhitespaceQType(testCase)
verifyError(testCase, @() Validate_Input('   ', 1, [1 2 -3], 0, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidQType');
end

function testAcceptsSpaceSeparatedAlias(testCase)
verifyWarningFree(testCase, @() Validate_Input('q const', 1, [1 2 -3], 0, 0.01, [4 8 16]));
end

function testAcceptsShortConstantAlias(testCase)
verifyWarningFree(testCase, @() Validate_Input('const', 1, [1 2 -3], 0, 0.01, [4 8 16]));
end

function testRejectsUnsupportedQType(testCase)
verifyError(testCase, @() Validate_Input('q_unknown', 1, [1 2 -3], 0, 0.01, [4 8 16]), ...
    'Validate_Input:UnsupportedQType');

function testRejectsMatrixQCoeff(testCase)
verifyError(testCase, @() Validate_Input('q_Const', [1 2; 3 4], [1 2 -3], 0, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidQCoeff');
end

function testRejectsMatrixLoadCoeff(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2; 3 4], 0, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidLoadCoeff');
end

function testRejectsInvalidQCoeff(testCase)
verifyError(testCase, @() Validate_Input('q_Const', [1 NaN], [1 2 -3], 0, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidQCoeff');

function testRejectsInvalidLoadCoeff(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [], 0, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidLoadCoeff');
end

function testRejectsComplexQCoeff(testCase)
verifyError(testCase, @() Validate_Input('q_Const', [1 2i], [1 2 -3], 0, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidQCoeff');
end

function testRejectsComplexLoadCoeff(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2i -3], 0, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidLoadCoeff');
end

function testRejectsInvalidDelta(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], [0 1], 0.01, [4 8 16]), ...
    'Validate_Input:InvalidDelta');

function testRejectsInvalidP(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, Inf, [4 8 16]), ...
    'Validate_Input:InvalidP');
end

function testRejectsNonScalarDelta(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], [0 1], 0.01, [4 8 16]), ...
    'Validate_Input:InvalidDelta');
end

function testRejectsNonScalarP(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, [0.01 0.02], [4 8 16]), ...
    'Validate_Input:InvalidP');
end

function testRejectsComplexDelta(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 1i, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidDelta');
end

function testRejectsComplexP(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, 1i, [4 8 16]), ...
    'Validate_Input:InvalidP');
end

function testRejectsInvalidElementsType(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, 0.01, 'bad'), ...
    'Validate_Input:InvalidElements');

function testRejectsEmptyElements(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, 0.01, []), ...
    'Validate_Input:InvalidElements');
end

function testRejectsInvalidElementsValues(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, 0.01, [4 7.5 16]), ...
    'Validate_Input:InvalidElements');
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, 0.01, [4 -8 16]), ...
    'Validate_Input:InvalidElements');
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, 0.01, [4 NaN 16]), ...
    'Validate_Input:InvalidElements');
end