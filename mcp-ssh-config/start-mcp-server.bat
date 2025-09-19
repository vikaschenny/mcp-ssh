@echo off
echo ========================================
echo Starting MCP SSH Server for Cursor AI
echo ========================================
echo.

REM Set SSH connection details
set SSH_HOST=10.20.17.38
set SSH_USERNAME=user1
set SSH_PASSWORD=g0]5(H0?

REM Check if Node.js is installed
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: Node.js is not installed or not in PATH
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

REM Check if dependencies are installed
if not exist "node_modules" (
    echo Installing dependencies...
    npm install
    if %errorlevel% neq 0 (
        echo Error: Failed to install dependencies
        pause
        exit /b 1
    )
)

echo.
echo Starting MCP SSH Server...
echo Server is configured to connect to:
echo   Host: %SSH_HOST%
echo   Username: %SSH_USERNAME%
echo.
echo The server is now running in MCP mode for Cursor AI integration.
echo.

REM Start the MCP server
node src/mcp-ssh-server.js
