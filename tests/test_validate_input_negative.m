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

function testRejectsInvalidQCoeff(testCase)
verifyError(testCase, @() Validate_Input('q_Const', [1 NaN], [1 2 -3], 0, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidQCoeff');

function testRejectsInvalidLoadCoeff(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [], 0, 0.01, [4 8 16]), ...
    'Validate_Input:InvalidLoadCoeff');

function testRejectsInvalidDelta(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], [0 1], 0.01, [4 8 16]), ...
    'Validate_Input:InvalidDelta');

function testRejectsInvalidP(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, Inf, [4 8 16]), ...
    'Validate_Input:InvalidP');

function testRejectsInvalidElementsType(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, 0.01, 'bad'), ...
    'Validate_Input:InvalidElements');

function testRejectsInvalidElementsValues(testCase)
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, 0.01, [4 7.5 16]), ...
    'Validate_Input:InvalidElements');
verifyError(testCase, @() Validate_Input('q_Const', 1, [1 2 -3], 0, 0.01, [4 -8 16]), ...
    'Validate_Input:InvalidElements');