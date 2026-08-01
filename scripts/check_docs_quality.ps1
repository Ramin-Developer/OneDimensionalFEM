$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
Set-Location $repoRoot

$failures = New-Object System.Collections.Generic.List[string]

$requiredFiles = @(
    'README.md',
    'docs/README.md',
    'docs/REFACTOR_PLAN.md',
    'docs/MODERNIZATION_PLAN.md',
    'docs/MODERNIZATION_BACKLOG.md',
    'docs/TODO.md'
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path $file)) {
        $failures.Add("Missing required file: $file")
    }
}

$markerChecks = @(
    @{ File = 'docs/README.md'; Marker = '## Documentation map' },
    @{ File = 'docs/MODERNIZATION_PLAN.md'; Marker = '## Session Log' },
    @{ File = 'docs/MODERNIZATION_BACKLOG.md'; Marker = '### MZ4. Add modernization quality checks' },
    @{ File = 'docs/TODO.md'; Marker = 'Execute MZ4 in [MODERNIZATION_BACKLOG.md](MODERNIZATION_BACKLOG.md)' }
)

foreach ($check in $markerChecks) {
    if (Test-Path $check.File) {
        $content = Get-Content -Raw -Path $check.File
        if ($content -notlike "*${($check.Marker)}*") {
            $failures.Add("Missing marker in $($check.File): $($check.Marker)")
        }
    }
}

$markdownFiles = @('README.md')
if (Test-Path 'docs') {
    $markdownFiles += Get-ChildItem -Path 'docs' -Recurse -File -Filter '*.md' | ForEach-Object { $_.FullName }
}
$markdownFiles = $markdownFiles | ForEach-Object {
    if ([System.IO.Path]::IsPathRooted($_)) {
        $_
    }
    else {
        Join-Path $repoRoot $_
    }
} | Sort-Object -Unique

$hardcodedPathPattern = '(?i)(d:/repos/code/onedimensionalfem|d:\\repos\\code\\onedimensionalfem)'
$linkPattern = '\[[^\]]+\]\(([^)]+)\)'

foreach ($filePath in $markdownFiles) {
    $relative = Resolve-Path -Path $filePath | ForEach-Object { $_.Path.Substring($repoRoot.Length + 1) }
    $content = Get-Content -Raw -Path $filePath

    if ($content -match $hardcodedPathPattern) {
        $failures.Add("Hard-coded local repo path found in $relative")
    }

    $lineNumber = 0
    foreach ($line in (Get-Content -Path $filePath)) {
        $lineNumber++
        $matches = [regex]::Matches($line, $linkPattern)
        foreach ($m in $matches) {
            $target = $m.Groups[1].Value.Trim()
            if ([string]::IsNullOrWhiteSpace($target)) {
                continue
            }
            if ($target.StartsWith('#') -or $target.StartsWith('http://') -or $target.StartsWith('https://') -or $target.StartsWith('mailto:')) {
                continue
            }

            $targetPath = $target
            if ($targetPath.Contains(' ')) {
                $targetPath = $targetPath.Split(' ')[0]
            }
            if ($targetPath.Contains('#')) {
                $targetPath = $targetPath.Split('#')[0]
            }
            if ([string]::IsNullOrWhiteSpace($targetPath)) {
                continue
            }

            $resolved = Join-Path (Split-Path -Parent $filePath) $targetPath
            if (-not (Test-Path $resolved)) {
                $failures.Add("Broken local link in ${relative}:$lineNumber -> $target")
            }
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host 'Documentation quality checks failed:'
    $failures | ForEach-Object { Write-Host "- $_" }
    exit 1
}

Write-Host 'Documentation quality checks passed.'
