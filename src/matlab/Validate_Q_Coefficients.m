function normalizedQType = Validate_Q_Coefficients(qType, qCoeff, errorPrefix)
%VALIDATE_Q_COEFFICIENTS Validate rigidity-model coefficients on [0, 1].

if nargin < 3
    errorPrefix = 'Validate_Q_Coefficients';
end

normalizedQType = Normalize_Q_Type(qType);
errorId = [errorPrefix ':InvalidQCoeff'];

if ~isnumeric(qCoeff) || ~isvector(qCoeff) || isempty(qCoeff) ...
        || any(~isfinite(qCoeff(:))) || any(~isreal(qCoeff(:)))
    error(errorId, 'q coefficients must be a finite real numeric vector.');
end

switch normalizedQType
    case 'q_const'
        if numel(qCoeff) ~= 1 || qCoeff(1) <= 0
            error(errorId, ...
                'Constant q requires one strictly positive coefficient.');
        end
    case {'q_frac_with_denom_1st_degree', 'q_frac_with_denom_2nd_degree'}
        if numel(qCoeff) ~= 2
            error(errorId, ...
                'Fractional q requires exactly two coefficients.');
        end

        scale = qCoeff(1);
        offset = qCoeff(2);
        isPositive = (scale > 0 && offset > 0) ...
            || (scale < 0 && offset < -1);
        if ~isPositive
            error(errorId, ...
                'Fractional q must be finite and strictly positive on [0, 1].');
        end
    case 'q_exp'
        if numel(qCoeff) ~= 1 || qCoeff(1) == 0
            error(errorId, ...
                'Exponential q requires one nonzero coefficient.');
        end
end