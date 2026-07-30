function normalizedQType = Normalize_Q_Type(qType)
%NORMALIZE_Q_TYPE Normalize supported q-type names to a canonical form.

normalizedQType = lower(strtrim(char(qType)));
normalizedQType = strrep(normalizedQType, '-', '_');
