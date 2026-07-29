function [meshSize, solutionSize, qFunc, loadFunc, x, uFEMLin, uFEMCub, uExact, relTol] = ...
    Build_Problem_Data(numElements, qType, loadCoeff, qCoeff, delta, P)
%BUILD_PROBLEM_DATA Build the FEM problem data and exact solution handlers.

assert(isnumeric(numElements) && isvector(numElements) && ~isempty(numElements), ...
    'Build_Problem_Data:InvalidNumElements', ...
    'numElements must be a non-empty numeric vector.');
assert(all(numElements > 0) && all(mod(numElements, 1) == 0), ...
    'Build_Problem_Data:InvalidNumElements', ...
    'numElements must contain positive integers.');
assert((ischar(qType) || isstring(qType)) && strlength(string(qType)) > 0, ...
    'Build_Problem_Data:InvalidQType', ...
    'qType must be a non-empty char or string.');
assert(isnumeric(loadCoeff) && ~isempty(loadCoeff), ...
    'Build_Problem_Data:InvalidLoadCoeff', ...
    'loadCoeff must be a non-empty numeric array.');
assert(isnumeric(qCoeff) && ~isempty(qCoeff), ...
    'Build_Problem_Data:InvalidQCoeff', ...
    'qCoeff must be a non-empty numeric array.');
assert(isnumeric(delta) && isscalar(delta) && isnumeric(P) && isscalar(P), ...
    'Build_Problem_Data:InvalidBoundaryData', ...
    'delta and P must be numeric scalars.');

meshSize = 1 ./ numElements;
solutionSize = 2^10;
x = linspace(0, 1, solutionSize + 1)';
uFEMLin = cell(1, numel(numElements));
uFEMCub = cell(1, numel(numElements));
relTol = 1e-12;

loadCoeff = Normalize_Load_Coefficients(loadCoeff);

normalizedQType = Normalize_Q_Type(qType);

switch normalizedQType
    case {'q_const', 'constant', 'const'}
        [qFunc, loadFunc, uExact] = Def_q_Const(loadCoeff, qCoeff, delta, P);
    case {'q_frac_with_denom_1st_degree', 'frac_with_denom_1st_degree', 'frac1'}
        [qFunc, loadFunc, uExact] = Def_q_Frac_Denom_1st_Degree(loadCoeff, qCoeff, delta, P);
    case {'q_frac_with_denom_2nd_degree', 'frac_with_denom_2nd_degree', 'frac2'}
        [qFunc, loadFunc, uExact] = Def_q_Frac_Denom_2nd_Degree(loadCoeff, qCoeff, delta, P);
    case {'exponential', 'exp', 'q_exp'}
        [qFunc, loadFunc, uExact] = Def_q_Exp(loadCoeff, qCoeff, delta, P);
    otherwise
        error('Build_Problem_Data:UnsupportedQType', ...
            'Unsupported qType: %s', char(qType));
end

function coeff = Normalize_Load_Coefficients(loadCoeff)

coeff = loadCoeff(:).';
if numel(coeff) < 3
    coeff = [coeff zeros(1, 3 - numel(coeff))];
end
coeff = coeff(1:3);

function normalizedQType = Normalize_Q_Type(qType)

normalizedQType = lower(strtrim(char(qType)));
normalizedQType = strrep(normalizedQType, '-', '_');

function [qFunction, loadFunc, uExact] = Def_q_Const(loadCoeff, qCoeff, delta, P)

coeffs = zeros(1, 5);
qFunction = @(x) qCoeff(1) * x.^0;
loadFunc = @(x) loadCoeff(1) + loadCoeff(2) * x + loadCoeff(3) * x.^2;

coeffs(1) = delta;
coeffs(2) = (P + loadCoeff(1) + loadCoeff(2) / 2 + loadCoeff(3) / 3) / qCoeff(1);
coeffs(3) = -loadCoeff(1) / (2 * qCoeff(1));
coeffs(4) = -loadCoeff(2) / (6 * qCoeff(1));
coeffs(5) = -loadCoeff(3) / (12 * qCoeff(1));

uExact = @(x) coeffs(1) + coeffs(2) * x + coeffs(3) * x.^2 + coeffs(4) * x.^3 + coeffs(5) * x.^4;

function [qFunction, loadFunc, uExact] = Def_q_Frac_Denom_1st_Degree(loadCoeff, qCoeff, delta, P)

coeffs = zeros(1, 6);
qFunction = @(x) qCoeff(1) ./ (x + qCoeff(2));
loadFunc = @(x) loadCoeff(1) + loadCoeff(2) * x + loadCoeff(3) * x.^2;

coeffs(1) = delta;
coeffs(2) = qCoeff(2) * P / qCoeff(1) + qCoeff(2) * loadCoeff(1) / qCoeff(1) + qCoeff(2) * loadCoeff(2) / (2 * qCoeff(1)) + qCoeff(2) * loadCoeff(3) / (3 * qCoeff(1));
coeffs(3) = P / (2 * qCoeff(1)) + (1 - qCoeff(2)) * loadCoeff(1) / (2 * qCoeff(1)) + loadCoeff(2) / (4 * qCoeff(1)) + loadCoeff(3) / (6 * qCoeff(1));
coeffs(4) = -loadCoeff(1) / (3 * qCoeff(1)) - qCoeff(2) * loadCoeff(2) / (6 * qCoeff(1));
coeffs(5) = -loadCoeff(2) / (8 * qCoeff(1)) - qCoeff(2) * loadCoeff(3) / (12 * qCoeff(1));
coeffs(6) = -loadCoeff(3) / (15 * qCoeff(1));

uExact = @(x) coeffs(1) + coeffs(2) * x + coeffs(3) * x.^2 + coeffs(4) * x.^3 + coeffs(5) * x.^4 + coeffs(6) * x.^5;

function [qFunction, loadFunc, uExact] = Def_q_Frac_Denom_2nd_Degree(loadCoeff, qCoeff, delta, P)

coeffs = zeros(1, 7);
qFunction = @(x) qCoeff(1) ./ (x.^2 + qCoeff(2));
loadFunc = @(x) loadCoeff(1) + loadCoeff(2) * x + loadCoeff(3) * x.^2;

coeffs(1) = delta;
coeffs(2) = qCoeff(2) * P / qCoeff(1) + qCoeff(2) * loadCoeff(1) / qCoeff(1) + qCoeff(2) * loadCoeff(2) / (2 * qCoeff(1)) + qCoeff(2) * loadCoeff(3) / (3 * qCoeff(1));
coeffs(3) = -qCoeff(2) * loadCoeff(1) / (2 * qCoeff(1));
coeffs(4) = P / (3 * qCoeff(1)) + loadCoeff(1) / (3 * qCoeff(1)) + (1 - qCoeff(2)) * loadCoeff(2) / (6 * qCoeff(1)) + loadCoeff(3) / (9 * qCoeff(1));
coeffs(5) = -loadCoeff(1) / (4 * qCoeff(1)) - qCoeff(2) * loadCoeff(3) / (12 * qCoeff(1));
coeffs(6) = -loadCoeff(2) / (10 * qCoeff(1));
coeffs(7) = -loadCoeff(3) / (18 * qCoeff(1));

uExact = @(x) coeffs(1) + coeffs(2) * x + coeffs(3) * x.^2 + coeffs(4) * x.^3 + coeffs(5) * x.^4 + coeffs(6) * x.^5 + coeffs(7) * x.^6;

function [qFunction, loadFunc, uExact] = Def_q_Exp(loadCoeff, qCoeff, delta, P)

coeffs = zeros(1, 5);
alpha = qCoeff(1);
qFunction = @(x) exp(-alpha * x);
loadFunc = @(x) loadCoeff(1) + loadCoeff(2) * x + loadCoeff(3) * x.^2;

coeffs(1) = delta - loadCoeff(1) / alpha - loadCoeff(2) / (2 * alpha) - loadCoeff(3) / (3 * alpha) - loadCoeff(1) / alpha^2 + loadCoeff(2) / alpha^3 - 2 * loadCoeff(3) / alpha^4 - P / alpha;
coeffs(2) = loadCoeff(1) / alpha + loadCoeff(2) / (2 * alpha) + loadCoeff(3) / (3 * alpha) + loadCoeff(1) / alpha^2 - loadCoeff(2) / alpha^3 + 2 * loadCoeff(3) / alpha^4 + P / alpha;
coeffs(3) = -loadCoeff(1) / alpha + loadCoeff(2) / alpha^2 - 2 * loadCoeff(3) / alpha^3;
coeffs(4) = -loadCoeff(2) / (2 * alpha) + loadCoeff(3) / alpha^2;
coeffs(5) = -loadCoeff(3) / (3 * alpha);

uExact = @(x) coeffs(1) + (coeffs(2) + coeffs(3) * x + coeffs(4) * x.^2 + coeffs(5) * x.^3) .* exp(alpha * x);
