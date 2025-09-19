# Simplified SSH Server Installation Script for Windows
Write-Host "=== SSH Server Installation for Cursor ===" -ForegroundColor Cyan
Write-Host ""

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "Node.js is not installed. Please install Node.js first." -ForegroundColor Red
    Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check npm
try {
    $npmVersion = npm --version
    Write-Host "npm found: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "npm is not installed." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Installing dependencies..." -ForegroundColor Yellow
Set-Location -Path $PSScriptRoot

# Install packages
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to install npm packages" -ForegroundColor Red
    exit 1
}
Write-Host "Dependencies installed successfully" -ForegroundColor Green

Write-Host ""
Write-Host "Testing SSH connection..." -ForegroundColor Yellow

# Test the connection
node test-connection.js
if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Connection test successful!" -ForegroundColor Green
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Your Linux server is configured:" -ForegroundColor Cyan
Write-Host "  Host: 10.20.17.38" -ForegroundColor White
Write-Host "  Username: user1" -ForegroundColor White
Write-Host "  Port: 22" -ForegroundColor White
Write-Host ""
Write-Host "To start the SSH server:" -ForegroundColor Yellow
Write-Host "  npm start" -ForegroundColor White
Write-Host ""
Write-Host "To use CLI mode:" -ForegroundColor Yellow
Write-Host "  npm run cli" -ForegroundColor White
Write-Host ""
Write-Host "The server will run on http://localhost:3000" -ForegroundColor Cyan
Write-Host ""