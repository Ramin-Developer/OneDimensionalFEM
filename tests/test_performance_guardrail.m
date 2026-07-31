function tests = test_performance_guardrail
%TEST_PERFORMANCE_GUARDRAIL Verify deterministic guardrail evaluation.

tests = functiontests(localfunctions);
end

function setupOnce(~)
testDir = fileparts(mfilename('fullpath'));
addpath(fullfile(fileparts(testDir), 'scripts'));
end

function testAcceptsObservationsWithinLimits(~)
baseline = performance_baseline;
timings = BuildTimings(baseline.numElementsList, [0.03 0.05 0.08]);
memoryStats = BuildMemoryStats( ...
    baseline.numElementsList, [0.10 0.05 0.025]);

status = evaluate_performance_guardrail(timings, memoryStats, baseline);

assert(status.overCount == 0);
assert(~any(status.isRuntimeOverThreshold));
assert(~any(status.isMemoryOverThreshold));
assert(all(isfinite(status.medianToReferenceRatio)));
end

function testReportsRuntimeAndMemoryRegressionsWithoutThrowing(~)
baseline = performance_baseline;
timings = BuildTimings(baseline.numElementsList, [0.03 0.25 0.08]);
memoryStats = BuildMemoryStats( ...
    baseline.numElementsList, [0.10 0.05 0.04]);

status = evaluate_performance_guardrail(timings, memoryStats, baseline);

assert(status.overCount == 2);
assert(status.isRuntimeOverThreshold(2));
assert(status.isMemoryOverThreshold(3));
end

function timings = BuildTimings(numElements, medians)
timings = [numElements(:), medians(:), medians(:), medians(:)];
timings(:, 3) = medians(:);
end

function memoryStats = BuildMemoryStats(numElements, ratios)
denseBytes = 100000 .* ones(numel(numElements), 1);
sparseBytes = denseBytes .* ratios(:);
memoryStats = [numElements(:), sparseBytes, denseBytes, ratios(:)];
end