function [timings, status, memoryStats] = ci_performance_guardrail( ...
    repeatCount, numElementsList, medianThresholdSeconds, memoryThresholdRatio)
%CI_PERFORMANCE_GUARDRAIL Informational performance check for CI/nightly runs.
%
%   [timings, status, memoryStats] = CI_PERFORMANCE_GUARDRAIL() benchmarks
%   representative mesh sizes and reports runtime and memory guardrail results
%   without failing the run.
%
%   This is intentionally informational: it emits warnings/summary output but
%   does not raise assertions intended to fail CI jobs.

baseline = performance_baseline;

if nargin < 1 || isempty(repeatCount)
    repeatCount = 5;
end
if nargin < 2 || isempty(numElementsList)
    numElementsList = baseline.numElementsList;
end
usesDefaultMeshes = isequal(numElementsList(:), baseline.numElementsList(:));
if nargin < 3 || isempty(medianThresholdSeconds)
    if usesDefaultMeshes
        medianThresholdSeconds = baseline.medianThresholdSeconds;
    else
        medianThresholdSeconds = inf(size(numElementsList));
    end
end
if nargin < 4 || isempty(memoryThresholdRatio)
    if usesDefaultMeshes
        memoryThresholdRatio = baseline.memoryThresholdRatio;
    else
        memoryThresholdRatio = ones(size(numElementsList));
    end
end

assert(isnumeric(repeatCount) && isscalar(repeatCount) && repeatCount >= 1 ...
    && mod(repeatCount, 1) == 0, ...
    'ci_performance_guardrail:InvalidRepeatCount', ...
    'repeatCount must be a positive integer scalar.');
assert(isnumeric(numElementsList) && isvector(numElementsList) ...
    && ~isempty(numElementsList) && all(numElementsList > 0) ...
    && all(mod(numElementsList, 1) == 0), ...
    'ci_performance_guardrail:InvalidNumElementsList', ...
    'numElementsList must be a non-empty vector of positive integers.');
assert(isnumeric(medianThresholdSeconds) && isvector(medianThresholdSeconds) ...
    && numel(medianThresholdSeconds) == numel(numElementsList) ...
    && all(medianThresholdSeconds > 0), ...
    'ci_performance_guardrail:InvalidThresholds', ...
    'medianThresholdSeconds must be positive and match numElementsList length.');
assert(isnumeric(memoryThresholdRatio) && isvector(memoryThresholdRatio) ...
    && numel(memoryThresholdRatio) == numel(numElementsList) ...
    && all(memoryThresholdRatio > 0), ...
    'ci_performance_guardrail:InvalidMemoryThresholds', ...
    'memoryThresholdRatio must be positive and match numElementsList length.');

addpath('scripts');

baseline.numElementsList = numElementsList;
baseline.medianThresholdSeconds = medianThresholdSeconds;
baseline.memoryThresholdRatio = memoryThresholdRatio;
if ~usesDefaultMeshes
    baseline.referenceMedianSeconds = nan(size(numElementsList));
end
[timings, memoryStats] = benchmark_solver(repeatCount, numElementsList);
status = evaluate_performance_guardrail(timings, memoryStats, baseline);

fprintf('Performance guardrail check (informational):\n');
fprintf('Baseline: %s\n', status.baselineVersion);
fprintf('N    median_sec    baseline_ratio   runtime_limit    memory_ratio    memory_limit    status\n');
for idx = 1:numel(numElementsList)
    tag = 'OK';
    if status.isRuntimeOverThreshold(idx) || status.isMemoryOverThreshold(idx)
        tag = 'ABOVE';
    end
    fprintf('%-4d %-13.6f %-16.3f %-16.6f %-15.6f %-15.6f %s\n', ...
        numElementsList(idx), status.medianSeconds(idx), ...
        status.medianToReferenceRatio(idx), status.thresholdSeconds(idx), ...
        status.sparseToDenseRatio(idx), status.memoryThresholdRatio(idx), tag);
end

if status.overCount > 0
    warning('ci_performance_guardrail:AboveThreshold', ...
        '%d benchmark points exceeded informational median thresholds.', status.overCount);
else
    disp('All benchmark medians are within informational thresholds.');
end

write_step_summary(status);

end

function write_step_summary(status)

summaryPath = getenv('GITHUB_STEP_SUMMARY');
if isempty(summaryPath)
    return;
end

fid = fopen(summaryPath, 'a');
if fid == -1
    warning('ci_performance_guardrail:SummaryOpenFailed', ...
        'Unable to open GITHUB_STEP_SUMMARY.');
    return;
end
cleaner = onCleanup(@() fclose(fid));

fprintf(fid, '## Nightly Performance Guardrail\n\n');
fprintf(fid, '- Informational only: this check does not fail CI.\n');
fprintf(fid, '- Baseline version: `%s`\n', status.baselineVersion);
fprintf(fid, '- Points above threshold: **%d**\n\n', status.overCount);
fprintf(fid, '| N | median s | baseline ratio | runtime limit s | sparse/dense | memory limit | status |\n');
fprintf(fid, '|---:|---:|---:|---:|---:|---:|:---|\n');

for idx = 1:numel(status.numElementsList)
    label = 'OK';
    if status.isRuntimeOverThreshold(idx) || status.isMemoryOverThreshold(idx)
        label = 'ABOVE';
    end

    fprintf(fid, '| %d | %.6f | %.3f | %.6f | %.6f | %.6f | %s |\n', ...
        status.numElementsList(idx), status.medianSeconds(idx), ...
        status.medianToReferenceRatio(idx), status.thresholdSeconds(idx), ...
        status.sparseToDenseRatio(idx), status.memoryThresholdRatio(idx), label);
end

fprintf(fid, '\n');

clear cleaner;
end
