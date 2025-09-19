I'll help you configure the MCP SSH server to run separately and integrate it with Cursor AI. Let me create a proper MCP server configuration that Cursor can recognize.
Ran tool
Now let me create a proper MCP server implementation and configuration files:
Ran tool
Ran tool
Now let me update the package.json to include the MCP server script:
Ran tool
Now let me create a batch file to start the MCP server and a configuration guide:
Ran tool
Now let me create the Cursor AI configuration guide:
Ran tool
Now let me create a PowerShell script for easier setup:
Ran tool
Now let's test the setup script:
```bash
.\setup-cursor-integration.ps1
```
Let me fix the PowerShell script syntax error:
Ran tool
Now let's run the setup script again:
```bash
.\setup-cursor-integration.ps1
```
Let me fix the ampersand issue:
Ran tool
Now let's run the setup script:
```bash
.\setup-cursor-integration.ps1
```
Let me check the file for the missing brace:
Ran tool
Ran tool
The issue is with the special character in the password. Let me fix it by escaping properly:
Ran tool
Ran tool
Now let's run the setup script:
```bash
.\setup-cursor-integration.ps1
```
Let me rewrite the setup script to fix all issues:
Ran tool
Now let's run the new setup script:
```bash
.\setup-cursor.ps1
```
Perfect! The setup is complete. Let me create a summary of what we've accomplished:

## ✅ MCP SSH Server Setup Complete!

### 🎉 What We've Set Up:

1. **Created MCP SSH Server** (`src/mcp-ssh-server.js`)
   - Fully compatible with Cursor AI's MCP protocol
   - Provides SSH tools for remote Linux server access

2. **Configuration Files Created**:
   - `cursor-mcp-config.json` - Ready to copy to Cursor settings
   - `start-mcp-server.bat` - Easy server startup
   - `setup-cursor.ps1` - Automated setup script
   - Desktop shortcut for quick server launch

### 📋 To Complete the Integration:

#### Step 1: Add to Cursor Settings
1. Open Cursor AI
2. Press `Ctrl+Shift+P`
3. Type: `Preferences: Open User Settings (JSON)`
4. Add this configuration (from `cursor-mcp-config.json`):

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

{
  "mcpServers": {
    "mcp-ssh-local": {
      "command": "powershell.exe",
      "args": ["-Command", "node C:\\poc_demo_working\\mcp-ssh-config\\src\\mcp-ssh-server-with-key.js"],
      "env": {
        "SSH_HOST": "198.168.1.1",
        "SSH_USERNAME": "user",
        "SSH_PRIVATE_KEY_PATH": "C:\\keys\\key.key",
        "SSH_PORT": "22"
      }
    }
  }
}
```

#### Step 2: Start the MCP Server
Use one of these methods:
- **Desktop Shortcut**: Double-click "MCP SSH Server" on your desktop
- **Command**: Run `npm start` in the `mcp-ssh-config` folder
- **Batch File**: Run `start-mcp-server.bat`

#### Step 3: Restart Cursor AI
Close and reopen Cursor to load the MCP server

### 🛠️ Available Tools in Cursor:

Once configured, you can use these tools in Cursor chat:

1. **`ssh_execute`** - Run commands
   ```
   "Use ssh_execute to run 'ls -la' on the Linux server"
   ```

2. **`ssh_upload`** - Upload files
   ```
   "Use ssh_upload to upload file.txt to the Linux server"
   ```

3. **`ssh_download`** - Download files
   ```
   "Use ssh_download to get ~/system_resources.json from the server"
   ```

4. **`ssh_list_files`** - List directory contents
   ```
   "Use ssh_list_files to show files in the home directory"
   ```

### 📁 Your Linux Server Scripts:
- `~/system_resources_simple.sh` - System monitoring
- `~/inbound_ports_proc.sh` - Network port monitoring
- `~/get_disk_details_fixed.sh` - Disk information

### 🔍 Test the Integration:

After setup, test in Cursor chat:
```
"Use ssh_execute to run ~/system_resources_simple.sh on the Linux server"
```

### 📂 File Structure:
```
C:\poc_demo\mcp-ssh-config\
├── src\
│   ├── mcp-ssh-server.js      # MCP server for Cursor
│   └── simple-ssh-server.js   # HTTP API server (alternative)
├── cursor-mcp-config.json     # Configuration to add to Cursor
├── start-mcp-server.bat       # Quick start script
├── setup-cursor.ps1           # Setup automation
└── CURSOR_SETUP_GUIDE.md      # Detailed documentation
```

The MCP SSH server is now ready to be integrated with Cursor AI! Just follow the 3 steps above to complete the setup.



I can see you're in the Cursor Settings under Tools & Integrations. Let me help you add the MCP SSH server to Cursor. You need to click on "New MCP Server" at the bottom of the MCP Tools list.
Ran tool
## 📋 Steps to Add MCP SSH Server to Cursor:

### Step 1: Click "New MCP Server"
Click the **"+ New MCP Server"** button at the bottom of your MCP Tools list (shown in your screenshot).

### Step 2: Configure the Server
When the configuration dialog opens, enter these details:

**Server Name:**
```
mcp-ssh-local
```

**Command:**
```
node
```

**Arguments:**
```
C:\poc_demo\mcp-ssh-config\src\mcp-ssh-server.js
```

**Environment Variables:**
Add these three environment variables:
- `SSH_HOST` = `10.20.17.
