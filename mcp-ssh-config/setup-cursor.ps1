# PowerShell Script to Set Up Cursor AI Integration with MCP SSH Server

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Cursor AI - MCP SSH Server Setup Script" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Get the current directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$mcpServerPath = Join-Path $scriptPath "src\mcp-ssh-server.js"

# Check if Node.js is installed
Write-Host "Checking Node.js installation..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version 2>$null
    Write-Host "Node.js $nodeVersion is installed" -ForegroundColor Green
} catch {
    Write-Host "Error: Node.js is not installed!" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Install dependencies
Write-Host ""
Write-Host "Installing dependencies..." -ForegroundColor Yellow
Set-Location $scriptPath
npm install
Write-Host "Dependencies installed successfully" -ForegroundColor Green

# Create cursor configuration
Write-Host ""
Write-Host "Creating Cursor configuration..." -ForegroundColor Yellow

$cursorConfig = @"
{
  "mcpServers": {
    "mcp-ssh-local": {
      "command": "node",
      "args": ["$($mcpServerPath.Replace('\', '\\'))"],
      "env": {
        "SSH_HOST": "10.20.17.38",
        "SSH_USERNAME": "user1",
        "SSH_PASSWORD": "g0]5(H0?"
      }
    }
  }
}
"@

# Save configuration
$configPath = Join-Path $scriptPath "cursor-mcp-config.json"
$cursorConfig | Set-Content $configPath
Write-Host "Configuration saved to: $configPath" -ForegroundColor Green

# Create desktop shortcut
Write-Host ""
Write-Host "Creating desktop shortcut..." -ForegroundColor Yellow
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "MCP SSH Server.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-NoExit -Command `"cd '$scriptPath'; npm start`""
$Shortcut.WorkingDirectory = $scriptPath
$Shortcut.IconLocation = "powershell.exe"
$Shortcut.Description = "Start MCP SSH Server for Cursor AI"
$Shortcut.Save()

Write-Host "Desktop shortcut created" -ForegroundColor Green

# Display instructions
Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Setup Complete!" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT - Manual Steps Required:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open Cursor Settings:" -ForegroundColor White
Write-Host "   - Press Ctrl+Shift+P" -ForegroundColor Gray
Write-Host "   - Type: 'Preferences: Open User Settings (JSON)'" -ForegroundColor Gray
Write-Host "   - Press Enter" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Add the MCP configuration:" -ForegroundColor White
Write-Host "   Copy the content from: $configPath" -ForegroundColor Gray
Write-Host "   And merge it into your settings.json" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Start the MCP Server:" -ForegroundColor White
Write-Host "   - Use the desktop shortcut 'MCP SSH Server'" -ForegroundColor Gray
Write-Host "   - Or run: npm start" -ForegroundColor Gray
Write-Host ""
Write-Host "4. Restart Cursor AI" -ForegroundColor White
Write-Host ""
Write-Host "Available Tools in Cursor:" -ForegroundColor Yellow
Write-Host "  - ssh_execute: Run commands on Linux server" -ForegroundColor Gray
Write-Host "  - ssh_upload: Upload files to Linux server" -ForegroundColor Gray
Write-Host "  - ssh_download: Download files from Linux server" -ForegroundColor Gray
Write-Host "  - ssh_list_files: List files on Linux server" -ForegroundColor Gray
Write-Host ""
Write-Host "Test command for Cursor chat:" -ForegroundColor Yellow
Write-Host "  'Use ssh_execute to run hostname on the Linux server'" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press Enter to open the configuration file..." -ForegroundColor Yellow
Read-Host

# Open the configuration file
notepad $configPath
