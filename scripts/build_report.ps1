$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $repoRoot 'docs\latex\source'
$outputDir = Join-Path $repoRoot 'docs\latex'

Remove-Item (Join-Path $outputDir 'main.tin'), `
    (Join-Path $outputDir 'main.sym'), `
    (Join-Path $outputDir 'main.glg') -ErrorAction SilentlyContinue

Push-Location $sourceDir
try {
    latexmk -pdf -interaction=nonstopmode -halt-on-error '-outdir=..' main.tex
    if ($LASTEXITCODE -ne 0) {
        throw "Initial LaTeX pass failed with exit code $LASTEXITCODE."
    }
} finally {
    Pop-Location
}

Push-Location $outputDir
try {
    makeglossaries main
    if ($LASTEXITCODE -ne 0) {
        throw "Glossary generation failed with exit code $LASTEXITCODE."
    }
} finally {
    Pop-Location
}

Push-Location $sourceDir
try {
    latexmk -g -pdf -interaction=nonstopmode -halt-on-error '-outdir=..' main.tex
    if ($LASTEXITCODE -ne 0) {
        throw "Final LaTeX pass failed with exit code $LASTEXITCODE."
    }
} finally {
    Pop-Location
}