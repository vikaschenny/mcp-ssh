# SSH Key Authentication Setup Guide for MCP Server

## 🔐 Authentication Methods Supported

The MCP SSH server supports multiple authentication methods:

1. **Password Only** - Simple password authentication
2. **Private Key (PEM)** - OpenSSH format private key
3. **Private Key (PPK)** - PuTTY format private key (needs conversion)
4. **Private Key with Passphrase** - Encrypted private key
5. **Both Password and Key** - Fallback authentication

## 📋 Configuration Examples

### 1️⃣ Password Authentication (Current Setup)

```json
{
  "mcpServers": {
    "mcp-ssh-local": {
      "command": "node",
      "args": ["C:\\poc_demo\\mcp-ssh-config\\src\\mcp-ssh-server-with-key.js"],
      "env": {
        "SSH_HOST": "10.20.17.38",
        "SSH_USERNAME": "user1",
        "SSH_PASSWORD": "g0]5(H0?"
      }
    }
  }
}
```

### 2️⃣ Private Key File (PEM/OpenSSH Format)

```json
{
  "mcpServers": {
    "mcp-ssh-local": {
      "command": "node",
      "args": ["C:\\poc_demo\\mcp-ssh-config\\src\\mcp-ssh-server-with-key.js"],
      "env": {
        "SSH_HOST": "10.20.17.38",
        "SSH_USERNAME": "user1",
        "SSH_PRIVATE_KEY_PATH": "C:\\Users\\YourUsername\\.ssh\\id_rsa"
      }
    }
  }
}
```

### 3️⃣ Private Key with Passphrase

```json
{
  "mcpServers": {
    "mcp-ssh-local": {
      "command": "node",
      "args": ["C:\\poc_demo\\mcp-ssh-config\\src\\mcp-ssh-server-with-key.js"],
      "env": {
        "SSH_HOST": "10.20.17.38",
        "SSH_USERNAME": "user1",
        "SSH_PRIVATE_KEY_PATH": "C:\\Users\\YourUsername\\.ssh\\id_rsa",
        "SSH_KEY_PASSPHRASE": "your-key-passphrase"
      }
    }
  }
}
```

### 4️⃣ Both Password and Key (Fallback)

```json
{
  "mcpServers": {
    "mcp-ssh-local": {
      "command": "node",
      "args": ["C:\\poc_demo\\mcp-ssh-config\\src\\mcp-ssh-server-with-key.js"],
      "env": {
        "SSH_HOST": "10.20.17.38",
        "SSH_USERNAME": "user1",
        "SSH_PASSWORD": "g0]5(H0?",
        "SSH_PRIVATE_KEY_PATH": "C:\\Users\\YourUsername\\.ssh\\id_rsa"
      }
    }
  }
}
```

## 🔄 Converting PPK to PEM

If you have a PuTTY private key (.ppk), you need to convert it to OpenSSH format:

### Method 1: Using PowerShell Script

```powershell
.\convert-ppk-to-pem.ps1 -PPKFile "C:\path\to\your-key.ppk"
```

### Method 2: Using PuTTYgen

1. Open PuTTYgen
2. Click "Load" and select your .ppk file
3. Go to Conversions → Export OpenSSH key
4. Save the file (e.g., as `id_rsa` without extension)

### Method 3: Using OpenSSL

```bash
ssh-keygen -i -f input.ppk > output.pem
```

## 🔑 Generating New SSH Keys

### On Windows (PowerShell)

```powershell
# Generate RSA key pair
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"

# Generate ED25519 key pair (recommended)
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Key Locations

Default key locations on Windows:
- `C:\Users\%USERNAME%\.ssh\id_rsa` (private key)
- `C:\Users\%USERNAME%\.ssh\id_rsa.pub` (public key)

## 🚀 Setting Up Key Authentication on Linux Server

1. **Copy your public key to the server:**

```bash
# From Windows PowerShell
type $env:USERPROFILE\.ssh\id_rsa.pub | ssh user1@10.20.17.38 "cat >> ~/.ssh/authorized_keys"
```

2. **Or manually on the Linux server:**

```bash
# On Linux server
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo "your-public-key-content" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

## 🔧 Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `SSH_HOST` | Server IP or hostname | `10.20.17.38` |
| `SSH_PORT` | SSH port (default: 22) | `22` or `2222` |
| `SSH_USERNAME` | SSH username | `user1` |
| `SSH_PASSWORD` | Password (optional with key) | `g0]5(H0?` |
| `SSH_PRIVATE_KEY_PATH` | Path to private key file | `C:\\Users\\John\\.ssh\\id_rsa` |
| `SSH_KEY_PASSPHRASE` | Private key passphrase | `my-secure-passphrase` |

## 📝 AWS EC2 Example

For AWS EC2 instances with .pem files:

```json
{
  "mcpServers": {
    "mcp-ssh-aws": {
      "command": "node",
      "args": ["C:\\poc_demo\\mcp-ssh-config\\src\\mcp-ssh-server-with-key.js"],
      "env": {
        "SSH_HOST": "ec2-xx-xx-xx-xx.compute.amazonaws.com",
        "SSH_USERNAME": "ec2-user",
        "SSH_PRIVATE_KEY_PATH": "C:\\aws\\keys\\my-instance.pem"
      }
    }
  }
}
```

## 🛡️ Security Best Practices

1. **Use Key-based Authentication** - More secure than passwords
2. **Protect Private Keys** - Set proper file permissions
3. **Use Passphrases** - Add an extra layer of security
4. **Rotate Keys Regularly** - Change keys periodically
5. **Never Share Private Keys** - Keep them secure and private

## 🐛 Troubleshooting

### Permission Denied

- Check key file permissions (should be readable only by you)
- Verify the public key is in `~/.ssh/authorized_keys` on server
- Check SSH server configuration allows key authentication

### Key Format Issues

- Ensure PEM format (starts with `-----BEGIN RSA PRIVATE KEY-----`)
- Convert PPK files to PEM format
- Remove Windows line endings if needed

### Connection Timeout

- Verify firewall rules
- Check SSH service is running on server
- Confirm correct port number

## 📚 Testing Your Configuration

After updating your Cursor settings with key authentication:

1. Restart Cursor AI
2. Test with: "Use ssh_execute to run 'whoami' on the Linux server"
3. Check the MCP server logs for connection details

## 🔄 Switching Authentication Methods

To switch between password and key authentication:

1. Update the environment variables in Cursor settings
2. Save the settings.json file
3. Restart Cursor AI
4. The new authentication method will be used

---

**Note:** The enhanced MCP server (`mcp-ssh-server-with-key.js`) supports all these authentication methods. Use the one that best fits your security requirements.
