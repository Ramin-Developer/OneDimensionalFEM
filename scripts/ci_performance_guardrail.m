function [timings, status] = ci_performance_guardrail(repeatCount, numElementsList, medianThresholdSeconds)
%CI_PERFORMANCE_GUARDRAIL Informational performance check for CI/nightly runs.
%
%   [timings, status] = CI_PERFORMANCE_GUARDRAIL() benchmarks representative
%   mesh sizes and reports median-time guardrail results without failing the run.
%
%   This is intentionally informational: it emits warnings/summary output but
%   does not raise assertions intended to fail CI jobs.

if nargin < 1 || isempty(repeatCount)
    repeatCount = 5;
end
if nargin < 2 || isempty(numElementsList)
    numElementsList = [8 16 32 64];
end
if nargin < 3 || isempty(medianThresholdSeconds)
    medianThresholdSeconds = [0.02 0.05 0.12 0.35];
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

addpath('scripts');

timings = benchmark_solver(repeatCount, numElementsList);
medians = timings(:, 3);
thresholds = medianThresholdSeconds(:);
isOver = medians > thresholds;

status = struct();
status.numElementsList = numElementsList(:);
status.medianSeconds = medians;
status.thresholdSeconds = thresholds;
status.isOverThreshold = isOver;
status.overCount = sum(isOver);

fprintf('Performance guardrail check (informational):\n');
fprintf('N    median_sec    threshold_sec    status\n');
for idx = 1:numel(numElementsList)
    tag = 'OK';
    if isOver(idx)
        tag = 'ABOVE';
    end
    fprintf('%-4d %-12.6f %-15.6f %s\n', ...
        numElementsList(idx), medians(idx), thresholds(idx), tag);
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
fprintf(fid, '- Points above threshold: **%d**\n\n', status.overCount);
fprintf(fid, '| N | median seconds | threshold seconds | status |\n');
fprintf(fid, '|---:|---:|---:|:---|\n');

for idx = 1:numel(status.numElementsList)
    label = 'OK';
    if status.isOverThreshold(idx)
        label = 'ABOVE';
    end

    fprintf(fid, '| %d | %.6f | %.6f | %s |\n', ...
        status.numElementsList(idx), status.medianSeconds(idx), ...
        status.thresholdSeconds(idx), label);
end

fprintf(fid, '\n');

clear cleaner;
end
