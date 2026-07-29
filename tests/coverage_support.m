function [coveragePlugin, coverageAttached, coverageXmlPath] = coverage_support(repoRoot, runner)
%COVERAGE_SUPPORT Create a coverage plugin when the current MATLAB version supports it.
%
%   The repository's coverage workflow uses Cobertura XML for summary output.
%   Older MATLAB releases, such as R2017a, do not expose the Cobertura format
%   class even though the generic CodeCoveragePlugin may exist. In that case we
%   skip coverage attachment and continue the test run without producing an XML
%   artifact.

coverageDir = fullfile(repoRoot, 'artifacts', 'coverage');
if exist(coverageDir, 'dir') ~= 7
    mkdir(coverageDir);
end

coverageXmlPath = fullfile(coverageDir, 'cobertura.xml');
coverageAttached = false;
coveragePlugin = [];

if exist('matlab.unittest.plugins.CodeCoveragePlugin', 'class') ~= 8
    return;
end

if exist('matlab.unittest.plugins.codecoverage.CoberturaFormat', 'class') ~= 8
    disp('Coverage plugin is unavailable in this MATLAB version; continuing without a coverage artifact.');
    return;
end

try
    coveragePlugin = matlab.unittest.plugins.CodeCoveragePlugin.forFolder( ...
        fullfile(repoRoot, 'src', 'matlab'), ...
        'IncludingSubfolders', true, ...
        'Producing', matlab.unittest.plugins.codecoverage.CoberturaFormat(coverageXmlPath));
    runner.addPlugin(coveragePlugin);
    coverageAttached = true;
catch ME
    warning('Coverage plugin setup failed: %s', ME.message);
end
end
