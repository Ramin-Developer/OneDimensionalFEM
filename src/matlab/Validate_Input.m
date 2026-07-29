function Validate_Input(q_Type, q_Coeff, load_Coeff, delta, P, num_Elements)
%VALIDATE_INPUT Validate model setup for the 1D FEM solver.
%
%   This validator uses only MATLAB R2017a-compatible syntax and catches
%   invalid configurations before numerical assembly starts.

supported_Types = { ...
    'q_Const', ...
    'q_Frac_With_Denom_1st_Degree', ...
    'q_Frac_With_Denom_2nd_Degree', ...
    'Exponential' ...
};

if ~ischar(q_Type)
    error('Validate_Input:InvalidQType', ...
    'q_Type must be a character vector.');
end

if ~any(strcmpi(char(q_Type), supported_Types))
    error('Validate_Input:UnsupportedQType', ...
        'Unsupported q_Type value: %s', char(q_Type));
end

if ~isnumeric(q_Coeff) || isempty(q_Coeff) || any(~isfinite(q_Coeff(:)))
    error('Validate_Input:InvalidQCoeff', ...
        'q_Coeff must be a finite numeric vector.');
end

if ~isnumeric(load_Coeff) || isempty(load_Coeff) || any(~isfinite(load_Coeff(:)))
    error('Validate_Input:InvalidLoadCoeff', ...
        'load_Coeff must be a finite numeric vector.');
end

if ~isscalar(delta) || ~isfinite(delta)
    error('Validate_Input:InvalidDelta', ...
        'delta must be a finite scalar.');
end

if ~isscalar(P) || ~isfinite(P)
    error('Validate_Input:InvalidP', ...
        'P must be a finite scalar.');
end

if ~isnumeric(num_Elements) || isempty(num_Elements) || any(~isfinite(num_Elements(:)))
    error('Validate_Input:InvalidElements', ...
        'num_Elements must be a finite numeric vector.');
end

if any(num_Elements(:) <= 0) || any(mod(num_Elements(:), 1) ~= 0)
    error('Validate_Input:InvalidElements', ...
        'num_Elements values must be positive integers.');
end
