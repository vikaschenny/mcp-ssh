# PowerShell script to help convert PPK to PEM format
# Requires PuTTYgen to be installed

param(
    [Parameter(Mandatory=$true)]
    [string]$PPKFile,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPEMFile = ""
)

Write-Host "PPK to PEM Converter for SSH Keys" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Check if PPK file exists
if (-not (Test-Path $PPKFile)) {
    Write-Host "Error: PPK file not found: $PPKFile" -ForegroundColor Red
    exit 1
}

# Set output file if not specified
if ($OutputPEMFile -eq "") {
    $OutputPEMFile = [System.IO.Path]::ChangeExtension($PPKFile, ".pem")
}

# Check if PuTTYgen is installed
$puttygenPath = $null
$possiblePaths = @(
    "C:\Program Files\PuTTY\puttygen.exe",
    "C:\Program Files (x86)\PuTTY\puttygen.exe",
    "$env:ProgramFiles\PuTTY\puttygen.exe",
    "${env:ProgramFiles(x86)}\PuTTY\puttygen.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $puttygenPath = $path
        break
    }
}

# Try to find puttygen in PATH
if (-not $puttygenPath) {
    $puttygenInPath = Get-Command puttygen.exe -ErrorAction SilentlyContinue
    if ($puttygenInPath) {
        $puttygenPath = $puttygenInPath.Path
    }
}

if ($puttygenPath) {
    Write-Host "Found PuTTYgen at: $puttygenPath" -ForegroundColor Green
    Write-Host "Converting PPK to PEM format..." -ForegroundColor Yellow
    
    # Convert PPK to OpenSSH format
    & $puttygenPath $PPKFile -O private-openssh -o $OutputPEMFile
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully converted to: $OutputPEMFile" -ForegroundColor Green
        Write-Host ""
        Write-Host "You can now use this PEM file in your Cursor configuration:" -ForegroundColor Yellow
        Write-Host '"SSH_PRIVATE_KEY_PATH": "' -NoNewline -ForegroundColor Gray
        Write-Host $OutputPEMFile.Replace('\', '\\') -NoNewline -ForegroundColor Cyan
        Write-Host '"' -ForegroundColor Gray
    } else {
        Write-Host "Error: Conversion failed" -ForegroundColor Red
    }
} else {
    Write-Host "PuTTYgen not found. Attempting manual conversion..." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual Conversion Instructions:" -ForegroundColor Cyan
    Write-Host "1. Download PuTTY from: https://www.putty.org/" -ForegroundColor White
    Write-Host "2. Open PuTTYgen" -ForegroundColor White
    Write-Host "3. Click 'Load' and select your PPK file: $PPKFile" -ForegroundColor White
    Write-Host "4. Go to Conversions -> Export OpenSSH key" -ForegroundColor White
    Write-Host "5. Save as: $OutputPEMFile" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternative: Use OpenSSL (if available)" -ForegroundColor Cyan
    Write-Host "Install OpenSSL and run:" -ForegroundColor White
    Write-Host "  ssh-keygen -i -f $PPKFile > $OutputPEMFile" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Yellow
Read-Host
