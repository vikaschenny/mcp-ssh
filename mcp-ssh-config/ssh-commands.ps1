# SSH Command Helper for Linux Server
# This script provides easy commands to interact with your Linux server

$baseUrl = "http://localhost:3000"

function Connect-LinuxServer {
    Write-Host "Connecting to Linux server..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/connect" -Method Post -ContentType "application/json" -Body '{}'
    if ($response.success) {
        Write-Host $response.message -ForegroundColor Green
    } else {
        Write-Host $response.message -ForegroundColor Red
    }
}

function Execute-LinuxCommand {
    param([string]$Command)
    
    $body = @{
        command = $Command
    } | ConvertTo-Json
    
    Write-Host "Executing: $Command" -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri "$baseUrl/execute" -Method Post -ContentType "application/json" -Body $body
    
    if ($response.success) {
        Write-Host $response.output -ForegroundColor White
        if ($response.error) {
            Write-Host "Errors:" -ForegroundColor Red
            Write-Host $response.error -ForegroundColor Red
        }
    } else {
        Write-Host $response.message -ForegroundColor Red
    }
}

function Get-ServerStatus {
    $response = Invoke-RestMethod -Uri "$baseUrl/status" -Method Get
    if ($response.connected) {
        Write-Host "Connected to:" -ForegroundColor Green
        Write-Host "  Host: $($response.serverDetails.host)" -ForegroundColor White
        Write-Host "  User: $($response.serverDetails.username)" -ForegroundColor White
    } else {
        Write-Host "Not connected to server" -ForegroundColor Yellow
    }
}

function Disconnect-LinuxServer {
    Write-Host "Disconnecting from Linux server..." -ForegroundColor Yellow
    $response = Invoke-RestMethod -Uri "$baseUrl/disconnect" -Method Post -ContentType "application/json" -Body '{}'
    Write-Host $response.message -ForegroundColor Green
}

# Show available commands
Write-Host "=== SSH Command Helper ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Available commands:" -ForegroundColor Yellow
Write-Host "  Connect-LinuxServer         - Connect to 10.20.17.38" -ForegroundColor White
Write-Host "  Execute-LinuxCommand        - Run a command on the server" -ForegroundColor White
Write-Host "  Get-ServerStatus           - Check connection status" -ForegroundColor White
Write-Host "  Disconnect-LinuxServer     - Disconnect from server" -ForegroundColor White
Write-Host ""
Write-Host "Examples:" -ForegroundColor Yellow
Write-Host '  Execute-LinuxCommand "ls -la"' -ForegroundColor Gray
Write-Host '  Execute-LinuxCommand "df -h"' -ForegroundColor Gray
Write-Host '  Execute-LinuxCommand "free -m"' -ForegroundColor Gray
Write-Host '  Execute-LinuxCommand "./get_disk_details.sh"' -ForegroundColor Gray
Write-Host ""

# Auto-connect on load
Connect-LinuxServer
