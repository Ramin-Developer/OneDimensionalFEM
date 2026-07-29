%RUN_TESTS_WITH_COVERAGE Execute tests and publish code-coverage summary.

scriptDir = fileparts(mfilename('fullpath'));
repoRoot = fileparts(scriptDir);

addpath(genpath(fullfile(repoRoot, 'src', 'matlab')));
addpath(scriptDir);

assert(exist(fullfile(repoRoot, 'src', 'matlab', 'Main_Program.m'), 'file') == 2, ...
    'Main_Program.m not found');

import matlab.unittest.TestRunner
import matlab.unittest.TestSuite
import matlab.unittest.plugins.CodeCoveragePlugin

suite = TestSuite.fromFolder(scriptDir, 'IncludingSubfolders', true);
runner = TestRunner.withTextOutput;

coverageDir = fullfile(repoRoot, 'artifacts', 'coverage');
if exist(coverageDir, 'dir') ~= 7
    mkdir(coverageDir);
end

coverageXmlPath = fullfile(coverageDir, 'cobertura.xml');
coverageAttached = false;

try
    coveragePlugin = CodeCoveragePlugin.forFolder( ...
        fullfile(repoRoot, 'src', 'matlab'), ...
        'IncludingSubfolders', true, ...
        'Producing', matlab.unittest.plugins.codecoverage.CoberturaFormat(coverageXmlPath));
    runner.addPlugin(coveragePlugin);
    coverageAttached = true;
catch ME
    warning('Coverage plugin setup failed: %s', ME.message);
end

results = runner.run(suite);
assert(all([results.Passed]), 'One or more tests failed.');

if coverageAttached && exist(coverageXmlPath, 'file') == 2
    summary = summarize_cobertura_coverage(coverageXmlPath);
    print_coverage_summary(summary);
    write_step_summary(summary);
else
    disp('Coverage artifact was not produced.');
end

disp('MATLAB tests passed.');

function summary = summarize_cobertura_coverage(xmlPath)

doc = xmlread(xmlPath);

coverageNode = doc.getElementsByTagName('coverage').item(0);
overallLineRate = str2double(char(coverageNode.getAttribute('line-rate')));
summary.overallPercent = 100 * overallLineRate;

classNodes = doc.getElementsByTagName('class');
fileCoverage = struct('file', {}, 'percent', {});

for idx = 0:classNodes.getLength - 1
    classNode = classNodes.item(idx);
    fileName = char(classNode.getAttribute('filename'));
    lineRate = str2double(char(classNode.getAttribute('line-rate')));

    fileCoverage(end + 1).file = fileName; %#ok<AGROW>
    fileCoverage(end).percent = 100 * lineRate;
end

% Keep first appearance only in case a file is represented multiple times.
[~, uniqueIdx] = unique({fileCoverage.file}, 'stable');
fileCoverage = fileCoverage(uniqueIdx);

allPercents = [fileCoverage.percent];
[~, sortIdx] = sort(allPercents, 'ascend');
fileCoverage = fileCoverage(sortIdx);

summary.files = fileCoverage;
summary.criticalThreshold = 60;
summary.lowThreshold = 80;
summary.critical = fileCoverage(allPercents(sortIdx) < summary.criticalThreshold);
summary.low = fileCoverage(allPercents(sortIdx) >= summary.criticalThreshold ...
    & allPercents(sortIdx) < summary.lowThreshold);
end

function print_coverage_summary(summary)

fprintf('Overall line coverage: %.2f%%\n', summary.overallPercent);

if isempty(summary.critical)
    disp('Critical coverage files (<60%): none');
else
    disp('Critical coverage files (<60%):');
    for idx = 1:numel(summary.critical)
        fprintf('  - %s: %.2f%%\n', summary.critical(idx).file, summary.critical(idx).percent);
    end
end

if isempty(summary.low)
    disp('Low coverage files (60%-<80%): none');
else
    disp('Low coverage files (60%-<80%):');
    for idx = 1:numel(summary.low)
        fprintf('  - %s: %.2f%%\n', summary.low(idx).file, summary.low(idx).percent);
    end
end
end

function write_step_summary(summary)

summaryPath = getenv('GITHUB_STEP_SUMMARY');
if isempty(summaryPath)
    return;
end

fid = fopen(summaryPath, 'a');
if fid == -1
    warning('Unable to open GITHUB_STEP_SUMMARY for writing.');
    return;
end
cleaner = onCleanup(@() fclose(fid));

fprintf(fid, '## MATLAB Coverage Summary\n\n');
fprintf(fid, '- Overall line coverage: **%.2f%%**\n', summary.overallPercent);
fprintf(fid, '- Critical threshold: < %.0f%%\n', summary.criticalThreshold);
fprintf(fid, '- Low threshold: %.0f%% to < %.0f%%\n\n', ...
    summary.criticalThreshold, summary.lowThreshold);

if isempty(summary.critical)
    fprintf(fid, '### Critical files\nNone\n\n');
else
    fprintf(fid, '### Critical files\n');
    for idx = 1:numel(summary.critical)
        fprintf(fid, '- `%s`: %.2f%%\n', summary.critical(idx).file, summary.critical(idx).percent);
    end
    fprintf(fid, '\n');
end

if isempty(summary.low)
    fprintf(fid, '### Low files\nNone\n\n');
else
    fprintf(fid, '### Low files\n');
    for idx = 1:numel(summary.low)
        fprintf(fid, '- `%s`: %.2f%%\n', summary.low(idx).file, summary.low(idx).percent);
    end
    fprintf(fid, '\n');
end

clear cleaner;
end