function normalizedQType = Normalize_Q_Type(qType)
%NORMALIZE_Q_TYPE Normalize supported q-type names to a canonical form.

isValidQType = (ischar(qType) && size(qType, 1) == 1 && ~isempty(qType)) ...
    || (isstring(qType) && isscalar(qType) && strlength(qType) > 0);
assert(isValidQType, ...
    'Normalize_Q_Type:InvalidQType', ...
    'qType must be a non-empty char or string.');
assert(~isempty(strtrim(char(qType))), ...
    'Normalize_Q_Type:InvalidQType', ...
    'qType must not be empty or whitespace-only.');

normalizedQType = lower(strtrim(char(qType)));
normalizedQType = strrep(normalizedQType, '-', '_');
normalizedQType = strrep(normalizedQType, ' ', '_');

switch normalizedQType
    case {'q_const', 'constant', 'const'}
        normalizedQType = 'q_const';
    case {'q_frac_with_denom_1st_degree', 'frac_with_denom_1st_degree', 'frac1'}
        normalizedQType = 'q_frac_with_denom_1st_degree';
    case {'q_frac_with_denom_2nd_degree', 'frac_with_denom_2nd_degree', 'frac2'}
        normalizedQType = 'q_frac_with_denom_2nd_degree';
    case {'exponential', 'exp', 'q_exp'}
        normalizedQType = 'q_exp';
    otherwise
        error('Normalize_Q_Type:UnsupportedQType', ...
            'Unsupported qType: %s', char(qType));
end
