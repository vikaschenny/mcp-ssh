@echo off
REM This batch file is specifically for Cursor AI MCP integration
REM It ensures the MCP server starts correctly

cd /d "%~dp0"
echo Starting MCP SSH Server for Cursor AI...
echo Current directory: %CD%
echo Node.js version:
node --version
echo.
echo Starting MCP server...
node src\mcp-ssh-server-with-key.js
