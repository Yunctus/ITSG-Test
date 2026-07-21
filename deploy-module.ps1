param(
    [string]$DestinationPath = "X:\PowerShell Scripts\MyModule",
    [switch]$IncrementVersion,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$SourceRoot = Get-Location
$ManifestPath = Join-Path $SourceRoot "MyModule.psd1"

Write-Host "========================================"
Write-Host "PowerShell Module Deployment Script"
Write-Host "========================================"
Write-Host ""

if (-not (Test-Path $ManifestPath)) {
    Write-Error "Manifest file not found: $ManifestPath"
    exit 1
}

Write-Host "Reading manifest: MyModule.psd1"
$manifestContent = Get-Content $ManifestPath -Raw
$versionMatch = $manifestContent | Select-String "ModuleVersion\s*=\s*'([^']*)'" 
if ($versionMatch) {
    $currentVersion = $versionMatch.Matches[0].Groups[1].Value
} else {
    Write-Error "Could not find ModuleVersion in manifest"
    exit 1
}
Write-Host "Current version: $currentVersion"

if ($IncrementVersion) {
    $versionParts = $currentVersion -split '\.'
    $newVersion = "{0}.{1}.$([int]$versionParts[2] + 1)" -f $versionParts[0], $versionParts[1]
    Write-Host "New version: $newVersion"
    
    $manifestContent = Get-Content $ManifestPath -Raw
    $manifestContent = $manifestContent -replace "ModuleVersion\s*=\s*'[^']*'", "ModuleVersion = '$newVersion'"
    Set-Content $ManifestPath -Value $manifestContent -Force -Encoding UTF8
    $currentVersion = $newVersion
}

if (-not (Test-Path $DestinationPath)) {
    Write-Host "Creating destination directory: $DestinationPath"
    New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
} else {
    Write-Host "Destination exists: $DestinationPath"
}

Write-Host ""
Write-Host "Copying module files..."

$excludePatterns = @('.git', '.gitignore', 'deploy-module.ps1', 'copy-with-versioning.ps1')
$filesToCopy = Get-ChildItem -Path $SourceRoot -Recurse | 
    Where-Object { 
        $fullPath = $_.FullName
        $relativePath = $fullPath.Substring($SourceRoot.Length + 1)
        $exclude = $false
        
        foreach ($pattern in $excludePatterns) {
            if ($relativePath -like "$pattern*") {
                $exclude = $true
                break
            }
        }
        
        -not $exclude -and -not $_.PSIsContainer
    }

$copiedCount = 0
foreach ($file in $filesToCopy) {
    $relativePath = $file.FullName.Substring($SourceRoot.Path.Length + 1)
    $destFile = Join-Path $DestinationPath $relativePath
    $destDir = Split-Path $destFile
    
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    Copy-Item -Path $file.FullName -Destination $destFile -Force
    Write-Host "  OK: $relativePath"
    $copiedCount++
}

Write-Host ""
Write-Host "Deployment Complete"
Write-Host "Files copied: $copiedCount"
Write-Host "Destination: $DestinationPath"
Write-Host "Module version: $currentVersion"
Write-Host ""

Write-Host "Deployment Information:"
Write-Host "  SourceRepository: Yunctus/ITSG-Test"
Write-Host "  DestinationPath: $DestinationPath"
Write-Host "  ModuleVersion: $currentVersion"
Write-Host "  FilesCopied: $copiedCount"
Write-Host ""

Write-Host "To use this module in PowerShell profile:"
Write-Host "  Import-Module '$DestinationPath' -Force"
Write-Host ""
