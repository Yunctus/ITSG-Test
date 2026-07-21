param(
    [string]$DestinationPath = "X:\PowerShell Scripts",
    [switch]$Force
)

$SourcePath = Get-Location
$VersionManifest = Join-Path $DestinationPath "VERSION_MANIFEST.json"

# Ensure destination exists
if (-not (Test-Path $DestinationPath)) {
    New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    Write-Host "Created destination directory: $DestinationPath"
}

# Load existing manifest or create new one
$manifest = @{
    lastUpdated = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
    sourceRepository = "Yunctus/ITSG-Test"
    sourceCommit = (git -C $SourcePath rev-parse HEAD)
    sourceRemote = (git -C $SourcePath config --get remote.origin.url)
    files = @()
}

if (Test-Path $VersionManifest) {
    $existingManifest = Get-Content $VersionManifest | ConvertFrom-Json
    $manifest.files = $existingManifest.files
}

# Get all files excluding .git and script itself
$filesToCopy = Get-ChildItem -Path $SourcePath -Recurse -Exclude @('.git', 'copy-with-versioning.ps1', 'VERSION_MANIFEST.json') |
    Where-Object { -not $_.PSIsContainer }

foreach ($file in $filesToCopy) {
    $relativePath = $file.FullName.Substring($SourcePath.Length + 1)
    $destFile = Join-Path $DestinationPath $relativePath
    $destDir = Split-Path $destFile
    
    # Create directory if needed
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    # Get file hash for versioning
    $currentHash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
    
    # Check if file needs updating
    $needsUpdate = $true
    $existingEntry = $manifest.files | Where-Object { $_.path -eq $relativePath }
    
    if ($existingEntry) {
        if ($existingEntry.hash -eq $currentHash) {
            $needsUpdate = $false
        }
    }
    
    if ($needsUpdate -or $Force) {
        Copy-Item -Path $file.FullName -Destination $destFile -Force
        
        # Update manifest
        if ($existingEntry) {
            $existingEntry.hash = $currentHash
            $existingEntry.lastCopied = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            $existingEntry.size = $file.Length
        } else {
            $manifest.files += @{
                path = $relativePath
                hash = $currentHash
                size = $file.Length
                firstCopied = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
                lastCopied = Get-Date -Format "yyyy-MM-ddTHH:mm:ss"
            }
        }
        
        Write-Host "Copied: $relativePath"
    } else {
        Write-Host "Skipped (unchanged): $relativePath"
    }
}

# Save manifest
$manifest | ConvertTo-Json -Depth 10 | Set-Content -Path $VersionManifest -Force
Write-Host "`nVersion manifest saved to: $VersionManifest"
Write-Host "Manifest content:`n"
Get-Content $VersionManifest | ConvertFrom-Json | ConvertTo-Json
