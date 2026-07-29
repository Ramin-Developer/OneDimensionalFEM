function report = profile_solver_hotpaths(numElementsList, repeatCount, topK, outputPath)
%PROFILE_SOLVER_HOTPATHS Profile solver hot paths for selected meshes.
%
%   report = PROFILE_SOLVER_HOTPATHS() profiles baseline runs and returns a
%   struct containing top functions by total time.
%
%   report = PROFILE_SOLVER_HOTPATHS(numElementsList, repeatCount, topK,
%   outputPath) customizes mesh sizes, repeat count, number of reported
%   hotspot entries, and optional report file path.

if nargin < 1 || isempty(numElementsList)
    numElementsList = [32 64];
end
if nargin < 2 || isempty(repeatCount)
    repeatCount = 3;
end
if nargin < 3 || isempty(topK)
    topK = 12;
end
if nargin < 4
    outputPath = '';
end

assert(isnumeric(numElementsList) && isvector(numElementsList) ...
    && ~isempty(numElementsList) && all(numElementsList > 0) ...
    && all(mod(numElementsList, 1) == 0), ...
    'profile_solver_hotpaths:InvalidNumElementsList', ...
    'numElementsList must be a non-empty vector of positive integers.');
assert(isnumeric(repeatCount) && isscalar(repeatCount) ...
    && repeatCount >= 1 && mod(repeatCount, 1) == 0, ...
    'profile_solver_hotpaths:InvalidRepeatCount', ...
    'repeatCount must be a positive integer scalar.');
assert(isnumeric(topK) && isscalar(topK) && topK >= 1 && mod(topK, 1) == 0, ...
    'profile_solver_hotpaths:InvalidTopK', ...
    'topK must be a positive integer scalar.');

addpath(genpath('src/matlab'));

qType = 'q_Const';
qCoeff = 1;
loadCoeff = [1 2 -3];
delta = 0;
P = 0.01;

[meshSize, ~, qFunc, loadFunc, ~, ~, ~, ~, relTol] = ...
    Def_Problem(numElementsList, qType, loadCoeff, qCoeff, delta, P);

profile clear;
profile on;

for idx = 1:numel(numElementsList)
    numElements = numElementsList(idx);
    for rep = 1:repeatCount
        Calc_FEM_Sol(numElements, meshSize(idx), delta, P, qFunc, loadFunc, relTol);
    end
end

profile off;
profileInfo = profile('info');
functionTable = profileInfo.FunctionTable;

if isempty(functionTable)
    report = struct('numElementsList', numElementsList, ...
        'repeatCount', repeatCount, ...
        'topFunctions', [], ...
        'totalProfiledTime', 0);
    return;
end

totalTimes = [functionTable.TotalTime];
[sortedTimes, sortedIdx] = sort(totalTimes, 'descend');
topCount = min(topK, numel(sortedIdx));

topFunctions = repmat(struct( ...
    'functionName', '', ...
    'completeName', '', ...
    'totalTime', 0, ...
    'numCalls', 0, ...
    'timePerCall', 0), topCount, 1);

for row = 1:topCount
    entry = functionTable(sortedIdx(row));
    topFunctions(row).functionName = entry.FunctionName;
    topFunctions(row).completeName = entry.CompleteName;
    topFunctions(row).totalTime = sortedTimes(row);
    topFunctions(row).numCalls = entry.NumCalls;
    if entry.NumCalls > 0
        topFunctions(row).timePerCall = sortedTimes(row) / entry.NumCalls;
    end
end

report = struct('numElementsList', numElementsList, ...
    'repeatCount', repeatCount, ...
    'topFunctions', topFunctions, ...
    'totalProfiledTime', sum(totalTimes));

disp('Top profiling hotspots (by total time):');
for row = 1:numel(topFunctions)
    fprintf('%2d) %-35s total=%0.6fs calls=%d perCall=%0.6es\n', ...
        row, topFunctions(row).functionName, ...
        topFunctions(row).totalTime, topFunctions(row).numCalls, ...
        topFunctions(row).timePerCall);
end

if ~isempty(outputPath)
    write_report(outputPath, report);
end

function write_report(outputPath, report)

fid = fopen(outputPath, 'w');
assert(fid ~= -1, 'profile_solver_hotpaths:FileOpenFailed', ...
    'Unable to write output file: %s', outputPath);
cleanupObj = onCleanup(@() fclose(fid));

fprintf(fid, 'PROFILE_SOLVER_HOTPATHS\n');
fprintf(fid, 'numElementsList: ');
fprintf(fid, '%d ', report.numElementsList);
fprintf(fid, '\nrepeatCount: %d\n', report.repeatCount);
fprintf(fid, 'totalProfiledTime: %.12g\n', report.totalProfiledTime);
fprintf(fid, 'TOP_FUNCTIONS\n');

for row = 1:numel(report.topFunctions)
    tf = report.topFunctions(row);
    fprintf(fid, '%d|%s|%.12g|%d|%.12g|%s\n', ...
        row, tf.functionName, tf.totalTime, tf.numCalls, ...
        tf.timePerCall, tf.completeName);
end

clear cleanupObj;