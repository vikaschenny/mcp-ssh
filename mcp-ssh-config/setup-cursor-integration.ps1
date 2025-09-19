# PowerShell Script to Set Up Cursor AI Integration with MCP SSH Server
# Run this script as Administrator for best results

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Cursor AI - MCP SSH Server Setup Script" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Get the current directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$mcpServerPath = Join-Path $scriptPath "src\mcp-ssh-server.js"

# Check if Node.js is installed
Write-Host "Checking Node.js installation..." -ForegroundColor Yellow
$nodeVersion = node --version 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Node.js is not installed!" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ Node.js $nodeVersion is installed" -ForegroundColor Green

# Install dependencies
Write-Host ""
Write-Host "Installing dependencies..." -ForegroundColor Yellow
Set-Location $scriptPath
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to install dependencies!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host "✓ Dependencies installed successfully" -ForegroundColor Green

# Find Cursor settings file
Write-Host ""
Write-Host "Looking for Cursor settings..." -ForegroundColor Yellow

$cursorSettingsPaths = @(
    "$env:APPDATA\Cursor\User\settings.json",
    "$env:USERPROFILE\.cursor\settings.json",
    "$env:LOCALAPPDATA\Programs\cursor\resources\app\out\vs\code\electron-sandbox\workbench\settings.json"
)

$settingsPath = $null
foreach ($path in $cursorSettingsPaths) {
    if (Test-Path $path) {
        $settingsPath = $path
        break
    }
}

if (-not $settingsPath) {
    Write-Host "Warning: Could not find Cursor settings.json file" -ForegroundColor Yellow
    Write-Host "You'll need to manually add the configuration to Cursor settings" -ForegroundColor Yellow
    
    # Create a config file for manual setup
    $configPath = Join-Path $scriptPath "cursor-config.json"
    $config = @{
        mcpServers = @{
            "mcp-ssh-local" = @{
                command = "node"
                args = @($mcpServerPath.Replace("\", "\\"))
                env = @{
                    SSH_HOST = "10.20.17.38"
                    SSH_USERNAME = "user1"
                    SSH_PASSWORD = 'g0]5(H0?'
                }
            }
        }
    }
    
    $config | ConvertTo-Json -Depth 10 | Set-Content $configPath
    Write-Host ""
    Write-Host "Configuration saved to: $configPath" -ForegroundColor Green
    Write-Host "Please copy this configuration to your Cursor settings.json" -ForegroundColor Yellow
} else {
    Write-Host "✓ Found Cursor settings at: $settingsPath" -ForegroundColor Green
    
    # Backup existing settings
    $backupPath = "$settingsPath.backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item $settingsPath $backupPath
    Write-Host "✓ Backup created: $backupPath" -ForegroundColor Green
    
    # Read existing settings
    $settings = Get-Content $settingsPath -Raw | ConvertFrom-Json
    
    # Add or update MCP server configuration
    if (-not $settings.mcpServers) {
        $settings | Add-Member -NotePropertyName "mcpServers" -NotePropertyValue @{} -Force
    }
    
    $settings.mcpServers."mcp-ssh-local" = @{
        command = "node"
        args = @($mcpServerPath)
        env = @{
            SSH_HOST = "10.20.17.38"
            SSH_USERNAME = "user1"
            SSH_PASSWORD = 'g0]5(H0?'
        }
    }
    
    # Save updated settings
    $settings | ConvertTo-Json -Depth 10 | Set-Content $settingsPath
    Write-Host "✓ Cursor settings updated successfully" -ForegroundColor Green
}

# Create desktop shortcut
Write-Host ""
Write-Host "Creating desktop shortcut..." -ForegroundColor Yellow
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "MCP SSH Server.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "cmd.exe"
$batchPath = Join-Path $scriptPath "start-mcp-server.bat"
$Shortcut.Arguments = "/k `"$batchPath`""
$Shortcut.WorkingDirectory = $scriptPath
$Shortcut.IconLocation = "cmd.exe"
$Shortcut.Description = "Start MCP SSH Server for Cursor AI"
$Shortcut.Save()

Write-Host "✓ Desktop shortcut created" -ForegroundColor Green

# Display summary
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "1. Start the MCP server using one of these methods:" -ForegroundColor White
Write-Host "   - Double-click the desktop shortcut 'MCP SSH Server'" -ForegroundColor Gray
Write-Host "   - Run: start-mcp-server.bat" -ForegroundColor Gray
Write-Host "   - Run: npm start" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Restart Cursor AI to load the new MCP server" -ForegroundColor White
Write-Host ""
Write-Host "3. Test the integration by asking Cursor to:" -ForegroundColor White
Write-Host "   'Use ssh_execute to run hostname on the Linux server'" -ForegroundColor Gray
Write-Host ""
Write-Host "SSH Server Details:" -ForegroundColor Yellow
Write-Host "  Host: 10.20.17.38" -ForegroundColor Gray
Write-Host "  Username: user1" -ForegroundColor Gray
Write-Host "  Scripts available on server:" -ForegroundColor Gray
Write-Host "    - ~/system_resources_simple.sh" -ForegroundColor Gray
Write-Host "    - ~/inbound_ports_proc.sh" -ForegroundColor Gray
Write-Host "    - ~/get_disk_details_fixed.sh" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Enter to exit..." -ForegroundColor Yellow
Read-Host
