function Validate_Input(q_Type, q_Coeff, load_Coeff, delta, P, num_Elements)
%VALIDATE_INPUT Validate model setup for the 1D FEM solver.
%
%   This validator uses only MATLAB R2017a-compatible syntax and catches
%   invalid configurations before numerical assembly starts.

supported_Types = { ...
    'q_Const', ...
    'q_Frac_With_Denom_1st_Degree', ...
    'q_Frac_With_Denom_2nd_Degree', ...
    'Exponential', ...
    'constant', ...
    'const', ...
    'frac_with_denom_1st_degree', ...
    'frac_with_denom_2nd_degree', ...
    'exp' ...
};

if ischar(q_Type)
    if size(q_Type, 1) ~= 1
        error('Validate_Input:InvalidQType', ...
            'q_Type must be a character vector or string scalar.');
    end
elseif isstring(q_Type) && isscalar(q_Type)
    % Accept scalar string input.
else
    error('Validate_Input:InvalidQType', ...
        'q_Type must be a character vector or string scalar.');
end

normalizedQType = lower(strtrim(char(q_Type)));
if isempty(normalizedQType)
    error('Validate_Input:InvalidQType', ...
        'q_Type must not be empty.');
end

if ~ischar(q_Type) || size(q_Type, 1) ~= 1 || any(isspace(normalizedQType))
    error('Validate_Input:InvalidQType', ...
        'q_Type must not contain whitespace-only content.');
end
normalizedQType = strrep(normalizedQType, '-', '_');
normalizedQType = strrep(normalizedQType, ' ', '_');

if ~any(strcmpi(normalizedQType, supported_Types))
    error('Validate_Input:UnsupportedQType', ...
        'Unsupported q_Type value: %s', char(q_Type));
end

if ~isnumeric(q_Coeff) || isempty(q_Coeff) || ~isvector(q_Coeff) || any(~isfinite(q_Coeff(:))) || any(~isreal(q_Coeff(:)))
    error('Validate_Input:InvalidQCoeff', ...
        'q_Coeff must be a finite real numeric vector.');
end

if ~isnumeric(load_Coeff) || isempty(load_Coeff) || ~isvector(load_Coeff) || any(~isfinite(load_Coeff(:))) || any(~isreal(load_Coeff(:)))
    error('Validate_Input:InvalidLoadCoeff', ...
        'load_Coeff must be a finite real numeric vector.');
end

if ~isscalar(delta) || ~isfinite(delta) || ~isreal(delta)
    error('Validate_Input:InvalidDelta', ...
        'delta must be a finite real scalar.');
end

if ~isscalar(P) || ~isfinite(P) || ~isreal(P)
    error('Validate_Input:InvalidP', ...
        'P must be a finite real scalar.');
end

if ~isnumeric(num_Elements) || isempty(num_Elements) || ~isvector(num_Elements) || any(~isfinite(num_Elements(:))) || any(~isreal(num_Elements(:)))
    error('Validate_Input:InvalidElements', ...
        'num_Elements must be a finite real numeric vector.');
end

if any(num_Elements(:) <= 0) || any(mod(num_Elements(:), 1) ~= 0)
    error('Validate_Input:InvalidElements', ...
        'num_Elements values must be positive integers.');
end
