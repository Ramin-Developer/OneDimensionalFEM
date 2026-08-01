$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$tempOutput = Join-Path $env:TEMP 'performance_hotspots.txt'

Push-Location $repoRoot
try {
    matlab -nosplash -nodesktop -wait -r "try; addpath('scripts'); run_profile_workflow([32 64],2,10,fullfile(tempdir,'performance_hotspots.txt')); catch ME; disp(getReport(ME,'extended')); exit(1); end; exit(0);"
    if ($LASTEXITCODE -ne 0) {
        throw "MATLAB profiling run failed with exit code $LASTEXITCODE."
    }
    Write-Host "Profiler report written to $tempOutput"
} finally {
    Pop-Location
}
