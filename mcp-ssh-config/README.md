# MCP SSH Server for Cursor

This is a custom MCP (Model Context Protocol) SSH server implementation that allows Cursor AI to connect to and interact with your Linux server securely.

## 📋 Server Details

- **Server IP**: 10.20.17.38
- **Username**: user1
- **Port**: 22 (default SSH port)

## 🚀 Quick Start

### Windows Installation

1. Open PowerShell as Administrator
2. Navigate to the `mcp-ssh-config` directory:
   ```powershell
   cd C:\poc_demo\mcp-ssh-config
   ```
3. Run the installation script:
   ```powershell
   .\install.ps1
   ```
4. Restart Cursor

### Linux/macOS Installation

1. Open Terminal
2. Navigate to the `mcp-ssh-config` directory:
   ```bash
   cd /path/to/poc_demo/mcp-ssh-config
   ```
3. Make the script executable and run it:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
4. Restart Cursor

## 🛠️ Manual Installation

If the automatic installation doesn't work, follow these steps:

1. **Install Dependencies**:
   ```bash
   cd mcp-ssh-config
   npm install
   ```

2. **Build the Server**:
   ```bash
   npm run build
   ```

3. **Configure Cursor**:
   
   Find your Cursor configuration file:
   - **Windows**: `%APPDATA%\Cursor\User\globalStorage\roaming\claude_desktop_config.json`
   - **macOS**: `~/Library/Application Support/Cursor/User/globalStorage/roaming/claude_desktop_config.json`
   - **Linux**: `~/.config/Cursor/User/globalStorage/roaming/claude_desktop_config.json`

   Add or update the configuration:
   ```json
   {
     "mcpServers": {
       "ssh-server": {
         "command": "node",
         "args": ["C:\\poc_demo\\mcp-ssh-config\\dist\\server.js"],
         "env": {
           "NODE_ENV": "production"
         }
       }
     }
   }
   ```
   
   **Note**: Replace `C:\\poc_demo\\mcp-ssh-config` with your actual path.

4. **Restart Cursor**

## 💬 Usage Examples

Once installed and Cursor is restarted, you can use natural language to interact with your Linux server:

### Basic Commands

- **"Connect to my Linux server"**
  - Establishes SSH connection to 10.20.17.38

- **"Show the disk usage on the Linux server"**
  - Runs `df -h` command

- **"List all files in the home directory"**
  - Runs `ls -la ~` command

- **"Show system information"**
  - Runs `uname -a` and other system info commands

### File Operations

- **"Upload my local config.txt to /home/user1/ on the server"**
  - Uploads a file from your local machine to the server

- **"Download /var/log/system.log from the server"**
  - Downloads a file from the server to your local machine

- **"Create a new directory called 'backup' in the home folder"**
  - Runs `mkdir ~/backup`

### Script Execution

- **"Run the disk details script on the server"**
  - Executes: `./get_disk_details.sh`

- **"Execute a Python script located at /home/user1/script.py"**
  - Runs: `python /home/user1/script.py`

### System Monitoring

- **"Show running processes"**
  - Runs `ps aux` or `top`

- **"Check memory usage"**
  - Runs `free -h`

- **"Show network connections"**
  - Runs `netstat -tuln`

### Package Management

- **"List installed packages"**
  - Runs appropriate package manager command

- **"Check if nginx is installed"**
  - Checks for nginx installation

## 🔧 Available Tools

The MCP server provides these tools to Cursor:

1. **ssh_connect**: Establish SSH connection
2. **ssh_execute**: Execute commands on the server
3. **ssh_upload**: Upload files to the server
4. **ssh_download**: Download files from the server
5. **ssh_list_dir**: List directory contents
6. **ssh_disconnect**: Close SSH connection

## 🔐 Security Notes

1. **Credentials**: The password is stored in the configuration. For production use, consider:
   - Using SSH key authentication instead of passwords
   - Storing credentials in environment variables
   - Using a secrets management system

2. **Network Security**:
   - Ensure your firewall allows SSH connections
   - Consider using VPN for additional security
   - Limit SSH access to specific IP addresses

3. **Best Practices**:
   - Regularly update the server's SSH configuration
   - Use strong passwords or SSH keys
   - Enable two-factor authentication if possible
   - Monitor SSH logs for unauthorized access attempts

## 📝 Troubleshooting

### Connection Issues

1. **"Connection refused" error**:
   - Verify the server IP is correct: 10.20.17.38
   - Check if SSH service is running on the server
   - Verify firewall settings

2. **"Authentication failed" error**:
   - Verify username and password are correct
   - Check if the user account is active
   - Ensure SSH password authentication is enabled

3. **"MCP server not found" in Cursor**:
   - Restart Cursor after installation
   - Check if Node.js is installed and in PATH
   - Verify the configuration file path is correct

### Command Execution Issues

1. **Commands not working**:
   - Ensure you're connected first
   - Check user permissions on the server
   - Verify the command syntax

2. **File transfer failures**:
   - Check file permissions
   - Verify paths are correct
   - Ensure sufficient disk space

### Checking Logs

To debug issues, check the Cursor developer console:
1. Open Cursor
2. Press `Ctrl+Shift+I` (Windows/Linux) or `Cmd+Option+I` (macOS)
3. Look for MCP-related messages in the Console tab

## 🔄 Updating

To update the MCP SSH server:

1. Pull the latest changes (if from a repository)
2. Run `npm install` to update dependencies
3. Run `npm run build` to rebuild
4. Restart Cursor

## 📚 Advanced Configuration

### Using SSH Keys

Instead of password authentication, you can use SSH keys:

1. Generate an SSH key pair (if you don't have one):
   ```bash
   ssh-keygen -t rsa -b 4096
   ```

2. Copy the public key to your server:
   ```bash
   ssh-copy-id user1@10.20.17.38
   ```

3. Update the connection configuration to use the private key instead of password

### Custom Port

If your SSH server runs on a non-standard port, update the `port` field in the configuration.

### Multiple Servers

You can configure connections to multiple servers by using different connection IDs.

## 🤝 Contributing

To improve this MCP server:

1. Edit the TypeScript source in `src/server.ts`
2. Add new tools or enhance existing ones
3. Run `npm run build` to compile
4. Test in Cursor
5. Document any new features

## 📄 License

MIT License - Feel free to modify and distribute as needed.

## 🆘 Support

If you encounter issues:

1. Check this README for solutions
2. Review the installation logs
3. Verify all prerequisites are installed
4. Check network connectivity to 10.20.17.38

## 🎯 Quick Test Commands

After installation, try these commands in Cursor to verify everything works:

1. **Test Connection**:
   - "Connect to the Linux server at 10.20.17.38"

2. **Test Command Execution**:
   - "Run 'whoami' on the server"
   - "Show the current date and time on the server"

3. **Test File Operations**:
   - "List files in /tmp on the server"
   - "Create a test file in /tmp"

4. **Test Your Scripts**:
   - "Run the get_disk_details.sh script"
   - "Show the output of the disk details script in JSON format"

## 📊 Monitoring Your Server

With this MCP server, you can easily monitor your Linux server:

- **Disk Space**: "Show disk usage in human-readable format"
- **Memory**: "Display memory statistics"
- **CPU**: "Show CPU usage and load average"
- **Processes**: "List top 10 processes by CPU usage"
- **Network**: "Show active network connections"
- **Logs**: "Display last 50 lines of system log"

Remember to restart Cursor after installation for the MCP server to be recognized!
