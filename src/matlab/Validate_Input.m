function Validate_Input(q_Type, q_Coeff, load_Coeff, delta, P, num_Elements)
%VALIDATE_INPUT Validate model setup for the 1D FEM solver.
%
%   This validator uses only MATLAB R2017a-compatible syntax and catches
%   invalid configurations before numerical assembly starts.

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

normalizedQType = strrep(normalizedQType, '-', '_');
normalizedQType = strrep(normalizedQType, ' ', '_');

try
    normalizedQType = Normalize_Q_Type(normalizedQType);
catch exception
    if strcmp(exception.identifier, 'Normalize_Q_Type:UnsupportedQType')
        error('Validate_Input:UnsupportedQType', ...
            'Unsupported q_Type value: %s', char(q_Type));
    end
    rethrow(exception);
end

Validate_Q_Coefficients(normalizedQType, q_Coeff, 'Validate_Input');

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
