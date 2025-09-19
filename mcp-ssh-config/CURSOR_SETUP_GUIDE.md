# Cursor AI - MCP SSH Server Setup Guide

## 📋 Prerequisites

1. **Node.js** installed on your Windows machine
2. **SSH access** to your Linux server (10.20.17.38)
3. **Cursor AI** installed and running

## 🚀 Quick Start

### Step 1: Install Dependencies

Open PowerShell or Command Prompt in the `mcp-ssh-config` directory and run:

```bash
npm install
```

### Step 2: Start the MCP Server

**Option A: Using the batch file (Recommended)**
```bash
start-mcp-server.bat
```

**Option B: Using npm**
```bash
npm start
```

**Option C: Direct node command**
```bash
node src/mcp-ssh-server.js
```

### Step 3: Configure Cursor AI

1. **Open Cursor Settings**
   - Press `Ctrl+,` (Windows) or `Cmd+,` (Mac)
   - Or go to File → Preferences → Settings

2. **Navigate to MCP Settings**
   - Search for "MCP" in the settings search bar
   - Or navigate to: Extensions → Model Context Protocol

3. **Add MCP Server Configuration**

   Click on "Edit in settings.json" and add the following configuration:

   ```json
   {
     "mcpServers": {
       "mcp-ssh-local": {
         "command": "node",
         "args": ["C:\\poc_demo\\mcp-ssh-config\\src\\mcp-ssh-server.js"],
         "env": {
           "SSH_HOST": "10.20.17.38",
           "SSH_USERNAME": "user1",
           "SSH_PASSWORD": "g0]5(H0?"
         }
       }
     }
   }
   ```

   **Alternative: Using npx (if installed globally)**
   ```json
   {
     "mcpServers": {
       "mcp-ssh-local": {
         "command": "npx",
         "args": ["-y", "C:\\poc_demo\\mcp-ssh-config"],
         "env": {
           "SSH_HOST": "10.20.17.38",
           "SSH_USERNAME": "user1",
           "SSH_PASSWORD": "g0]5(H0?"
         }
       }
     }
   }
   ```

4. **Restart Cursor AI**
   - Close and reopen Cursor AI to load the new MCP server

## 🛠️ Available Tools

Once configured, you'll have access to these tools in Cursor AI:

### 1. **ssh_execute**
Execute commands on your Linux server:
```
ssh_execute: Run "ls -la" on the Linux server
```

### 2. **ssh_upload**
Upload files to the Linux server:
```
ssh_upload: Upload local file.txt to ~/file.txt on the server
```

### 3. **ssh_download**
Download files from the Linux server:
```
ssh_download: Download ~/report.json from server to local
```

### 4. **ssh_list_files**
List files in a directory:
```
ssh_list_files: Show files in home directory on Linux server
```

## 🔧 Environment Variables

You can customize the SSH connection by setting environment variables:

- `SSH_HOST` - Linux server IP address (default: 10.20.17.38)
- `SSH_USERNAME` - SSH username (default: user1)
- `SSH_PASSWORD` - SSH password (default: g0]5(H0?)
- `SSH_PORT` - SSH port (default: 22)

## 📝 Testing the Integration

1. **Check MCP Server Status**
   - In Cursor AI, open the command palette (`Ctrl+Shift+P`)
   - Type "MCP: Show Server Status"
   - You should see "mcp-ssh-local" as connected

2. **Test a Simple Command**
   - In a new chat, try: "Use ssh_execute to run 'hostname' on the Linux server"
   - You should see the hostname of your Linux server

## 🐛 Troubleshooting

### Server Not Showing in Cursor

1. **Check the path** in settings.json is correct
2. **Ensure Node.js** is in your system PATH
3. **Restart Cursor AI** after configuration changes

### Connection Issues

1. **Verify SSH credentials** are correct
2. **Check firewall** allows SSH connections
3. **Test manual SSH** connection first:
   ```bash
   ssh user1@10.20.17.38
   ```

### Logs and Debugging

- MCP server logs are shown in Cursor's Output panel
- Select "Model Context Protocol" from the dropdown
- Check for connection errors or authentication issues

## 📁 File Structure

```
mcp-ssh-config/
├── src/
│   ├── mcp-ssh-server.js    # Main MCP server
│   └── simple-ssh-server.js  # HTTP API server (alternative)
├── package.json              # Node.js configuration
├── start-mcp-server.bat      # Windows startup script
└── CURSOR_SETUP_GUIDE.md     # This file
```

## 🔄 Updating the Server

To update the server configuration:

1. Edit `src/mcp-ssh-server.js` as needed
2. Restart the MCP server
3. Restart Cursor AI to reload the changes

## 💡 Tips

- Keep the MCP server running in a separate terminal window
- Use environment variables for sensitive information
- Test commands in the terminal first before using in Cursor
- The server maintains a persistent SSH connection for better performance

## 📚 Additional Resources

- [MCP Documentation](https://modelcontextprotocol.io/)
- [Cursor AI Documentation](https://cursor.sh/docs)
- [SSH2 Node.js Library](https://github.com/mscdex/ssh2)

## ✅ Success Indicators

When properly configured, you should see:
- "mcp-ssh-local" in Cursor's MCP servers list
- Ability to execute Linux commands from Cursor chat
- File transfer capabilities working both ways
- No authentication errors in the logs

---

For support or issues, check the logs in Cursor's Output panel or the terminal where the MCP server is running.
