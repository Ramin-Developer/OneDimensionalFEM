function outputPath = run_profile_workflow(meshSizes, repeatCount, topK, outputPath)
%RUN_PROFILE_WORKFLOW Run hotpath profiling with stable defaults.

if nargin < 1 || isempty(meshSizes)
    meshSizes = [32 64];
end
if nargin < 2 || isempty(repeatCount)
    repeatCount = 2;
end
if nargin < 3 || isempty(topK)
    topK = 10;
end
if nargin < 4 || isempty(outputPath)
    outputPath = fullfile(tempdir, 'performance_hotspots.txt');
end

profile_solver_hotpaths(meshSizes, repeatCount, topK, outputPath);
fprintf('Profiler report written to %s\n', outputPath);

end