#!/bin/bash

# MCP SSH Server Installation Script for Linux/macOS
# This script installs and configures the MCP SSH server for Cursor

echo -e "\033[36m=== MCP SSH Server Installation for Cursor ===\033[0m"
echo ""

# Check if Node.js is installed
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "\033[32m✓ Node.js found: $NODE_VERSION\033[0m"
else
    echo -e "\033[31m✗ Node.js is not installed. Please install Node.js first.\033[0m"
    echo -e "\033[33m  Download from: https://nodejs.org/\033[0m"
    exit 1
fi

# Check if npm is installed
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "\033[32m✓ npm found: $NPM_VERSION\033[0m"
else
    echo -e "\033[31m✗ npm is not installed.\033[0m"
    exit 1
fi

echo ""
echo -e "\033[33mInstalling dependencies...\033[0m"
cd "$(dirname "$0")"

# Install npm packages
npm install
if [ $? -ne 0 ]; then
    echo -e "\033[31m✗ Failed to install npm packages\033[0m"
    exit 1
fi
echo -e "\033[32m✓ Dependencies installed\033[0m"

echo ""
echo -e "\033[33mBuilding TypeScript files...\033[0m"
npm run build
if [ $? -ne 0 ]; then
    echo -e "\033[31m✗ Failed to build TypeScript files\033[0m"
    exit 1
fi
echo -e "\033[32m✓ Build completed\033[0m"

# Determine OS and set config path
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    CONFIG_DIR="$HOME/Library/Application Support/Cursor/User/globalStorage/roaming"
else
    # Linux
    CONFIG_DIR="$HOME/.config/Cursor/User/globalStorage/roaming"
fi

# Create directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

CONFIG_FILE="$CONFIG_DIR/claude_desktop_config.json"

echo ""
echo -e "\033[33mConfiguring Cursor MCP settings...\033[0m"

# Check if config file exists
if [ -f "$CONFIG_FILE" ]; then
    echo -e "\033[36m  Existing configuration found at: $CONFIG_FILE\033[0m"
    echo -e "\033[33m  Creating backup...\033[0m"
    BACKUP_FILE="${CONFIG_FILE}.backup_$(date +%Y%m%d_%H%M%S)"
    cp "$CONFIG_FILE" "$BACKUP_FILE"
    echo -e "\033[32m  Backup saved to: $BACKUP_FILE\033[0m"
fi

# Get current directory
SERVER_PATH=$(pwd)

# Create or update configuration
if [ -f "$CONFIG_FILE" ]; then
    # Update existing config using Node.js
    node -e "
    const fs = require('fs');
    const config = JSON.parse(fs.readFileSync('$CONFIG_FILE', 'utf8'));
    if (!config.mcpServers) config.mcpServers = {};
    config.mcpServers['ssh-server'] = {
        command: 'node',
        args: ['$SERVER_PATH/dist/server.js'],
        env: {
            NODE_ENV: 'production'
        }
    };
    fs.writeFileSync('$CONFIG_FILE', JSON.stringify(config, null, 2));
    "
else
    # Create new config
    cat > "$CONFIG_FILE" << EOF
{
  "mcpServers": {
    "ssh-server": {
      "command": "node",
      "args": ["$SERVER_PATH/dist/server.js"],
      "env": {
        "NODE_ENV": "production"
      }
    }
  }
}
EOF
fi

echo -e "\033[32m✓ Cursor configuration updated\033[0m"

echo ""
echo -e "\033[32m========================================\033[0m"
echo -e "\033[32mInstallation Complete!\033[0m"
echo -e "\033[32m========================================\033[0m"
echo ""
echo -e "\033[36mYour Linux server connection details:\033[0m"
echo "  Host: 10.20.17.38"
echo "  Username: user1"
echo "  Port: 22"
echo ""
echo -e "\033[33mNext steps:\033[0m"
echo "1. Restart Cursor to load the MCP server"
echo "2. Use the SSH tools in your conversations"
echo ""
echo -e "\033[36mExample commands you can use in Cursor:\033[0m"
echo '  "Connect to my Linux server"'
echo '  "Run ls -la on the Linux server"'
echo '  "Show disk usage on the Linux server"'
echo ""
echo -e "\033[33mConfiguration file saved at:\033[0m"
echo "  $CONFIG_FILE"
