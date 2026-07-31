function [meshSize, solutionSize, qFunc, loadFunc, ...
    x, uFEMLin, uFEMCub, uExact, relTol] = ...
    Def_Problem(numElements, q_Type, load_Coeff, q_Coeff, delta, P)

%DEF_PROBLEM Define problem data for FEM solve and post-processing.
%
% Input validation is owned by Build_Problem_Data to keep one authoritative
% implementation for problem configuration checks.

try
    [meshSize, solutionSize, qFunc, loadFunc, x, uFEMLin, uFEMCub, uExact, relTol] = ...
        Build_Problem_Data(numElements, q_Type, load_Coeff, q_Coeff, delta, P);
catch ME
    if startsWith(ME.identifier, 'Build_Problem_Data:')
        remappedId = strrep(ME.identifier, 'Build_Problem_Data:', 'Def_Problem:');
        throwAsCaller(MException(remappedId, '%s', ME.message));
    end
    rethrow(ME);
end

