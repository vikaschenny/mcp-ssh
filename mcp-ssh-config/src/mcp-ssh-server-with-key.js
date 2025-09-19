#!/usr/bin/env node

const { Client } = require('ssh2');
const readline = require('readline');
const fs = require('fs');
const path = require('path');

// SSH Configuration with support for both password and key authentication
const SSH_CONFIG = {
  host: process.env.SSH_HOST || '10.20.17.38',
  port: process.env.SSH_PORT || 22,
  username: process.env.SSH_USERNAME || 'user1',
  // Password authentication (optional if using key)
  password: process.env.SSH_PASSWORD || 'g0]5(H0?',
  // Key-based authentication (optional if using password)
  privateKey: process.env.SSH_PRIVATE_KEY_PATH ? 
    fs.readFileSync(process.env.SSH_PRIVATE_KEY_PATH) : 
    (process.env.SSH_PRIVATE_KEY || null),
  passphrase: process.env.SSH_KEY_PASSPHRASE || undefined,
  // Try keyboard-interactive auth if needed
  tryKeyboard: true,
  // Timeout
  readyTimeout: 20000
};

// Remove null/undefined authentication methods
if (!SSH_CONFIG.privateKey) {
  delete SSH_CONFIG.privateKey;
  delete SSH_CONFIG.passphrase;
}
if (!SSH_CONFIG.password && SSH_CONFIG.privateKey) {
  delete SSH_CONFIG.password;
}

class MCPSSHServer {
  constructor() {
    this.conn = new Client();
    this.isConnected = false;
    this.setupStdioInterface();
  }

  setupStdioInterface() {
    // Set up readline interface for stdio communication
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout,
      terminal: false
    });

    // Send initialization message
    this.sendResponse({
      jsonrpc: "2.0",
      result: {
        protocolVersion: "2024-11-05",
        capabilities: {
          tools: {
            listChanged: false
          }
        },
        serverInfo: {
          name: "mcp-ssh-local",
          version: "1.0.0"
        }
      }
    });

    // Listen for incoming messages
    this.rl.on('line', (line) => {
      try {
        const message = JSON.parse(line);
        this.handleMessage(message);
      } catch (error) {
        this.sendError(null, -32700, 'Parse error');
      }
    });
  }

  async handleMessage(message) {
    const { method, params, id } = message;

    switch (method) {
      case 'initialize':
        await this.handleInitialize(id, params);
        break;
      case 'tools/list':
        this.handleToolsList(id);
        break;
      case 'tools/call':
        await this.handleToolCall(id, params);
        break;
      default:
        this.sendError(id, -32601, 'Method not found');
    }
  }

  async handleInitialize(id, params) {
    // Connect to SSH server
    try {
      await this.connectSSH();
      
      this.sendResponse({
        jsonrpc: "2.0",
        id: id,
        result: {
          protocolVersion: "2024-11-05",
          capabilities: {
            tools: {
              listChanged: false
            }
          },
          serverInfo: {
            name: "mcp-ssh-local",
            version: "1.0.0"
          }
        }
      });
    } catch (error) {
      this.sendError(id, -32603, `SSH connection failed: ${error.message}`);
    }
  }

  handleToolsList(id) {
    this.sendResponse({
      jsonrpc: "2.0",
      id: id,
      result: {
        tools: [
          {
            name: "ssh_execute",
            description: "Execute a command on the remote Linux server",
            inputSchema: {
              type: "object",
              properties: {
                command: {
                  type: "string",
                  description: "The command to execute on the remote server"
                }
              },
              required: ["command"]
            }
          },
          {
            name: "ssh_upload",
            description: "Upload a file to the remote Linux server",
            inputSchema: {
              type: "object",
              properties: {
                localPath: {
                  type: "string",
                  description: "Local file path"
                },
                remotePath: {
                  type: "string",
                  description: "Remote file path on the Linux server"
                }
              },
              required: ["localPath", "remotePath"]
            }
          },
          {
            name: "ssh_download",
            description: "Download a file from the remote Linux server",
            inputSchema: {
              type: "object",
              properties: {
                remotePath: {
                  type: "string",
                  description: "Remote file path on the Linux server"
                },
                localPath: {
                  type: "string",
                  description: "Local file path to save to"
                }
              },
              required: ["remotePath", "localPath"]
            }
          },
          {
            name: "ssh_list_files",
            description: "List files in a directory on the remote Linux server",
            inputSchema: {
              type: "object",
              properties: {
                path: {
                  type: "string",
                  description: "Directory path on the remote server",
                  default: "~"
                }
              }
            }
          }
        ]
      }
    });
  }

  async handleToolCall(id, params) {
    const { name, arguments: args } = params;

    if (!this.isConnected) {
      try {
        await this.connectSSH();
      } catch (error) {
        this.sendError(id, -32603, `SSH connection failed: ${error.message}`);
        return;
      }
    }

    try {
      let result;
      switch (name) {
        case 'ssh_execute':
          result = await this.executeCommand(args.command);
          break;
        case 'ssh_upload':
          result = await this.uploadFile(args.localPath, args.remotePath);
          break;
        case 'ssh_download':
          result = await this.downloadFile(args.remotePath, args.localPath);
          break;
        case 'ssh_list_files':
          result = await this.listFiles(args.path || '~');
          break;
        default:
          this.sendError(id, -32602, 'Unknown tool');
          return;
      }

      this.sendResponse({
        jsonrpc: "2.0",
        id: id,
        result: {
          content: [
            {
              type: "text",
              text: result
            }
          ]
        }
      });
    } catch (error) {
      this.sendError(id, -32603, error.message);
    }
  }

  connectSSH() {
    return new Promise((resolve, reject) => {
      if (this.isConnected) {
        resolve();
        return;
      }

      // Log connection attempt (for debugging)
      const authMethod = SSH_CONFIG.privateKey ? 'private key' : 'password';
      console.error(`Connecting to ${SSH_CONFIG.host}:${SSH_CONFIG.port} using ${authMethod} authentication...`);

      this.conn.on('ready', () => {
        console.error('SSH connection established successfully');
        this.isConnected = true;
        resolve();
      });

      this.conn.on('error', (err) => {
        console.error('SSH connection error:', err.message);
        this.isConnected = false;
        reject(err);
      });

      this.conn.on('keyboard-interactive', (name, instructions, lang, prompts, finish) => {
        // Handle keyboard-interactive authentication
        if (prompts.length > 0 && SSH_CONFIG.password) {
          // Respond with password for all prompts
          finish([SSH_CONFIG.password]);
        } else {
          finish([]);
        }
      });

      try {
        this.conn.connect(SSH_CONFIG);
      } catch (error) {
        console.error('Failed to initiate SSH connection:', error.message);
        reject(error);
      }
    });
  }

  executeCommand(command) {
    return new Promise((resolve, reject) => {
      this.conn.exec(command, (err, stream) => {
        if (err) {
          reject(err);
          return;
        }

        let output = '';
        let errorOutput = '';

        stream.on('close', (code, signal) => {
          if (errorOutput) {
            resolve(`Output:\n${output}\n\nErrors:\n${errorOutput}`);
          } else {
            resolve(output);
          }
        });

        stream.on('data', (data) => {
          output += data.toString();
        });

        stream.stderr.on('data', (data) => {
          errorOutput += data.toString();
        });
      });
    });
  }

  uploadFile(localPath, remotePath) {
    return new Promise((resolve, reject) => {
      // Check if local file exists
      if (!fs.existsSync(localPath)) {
        reject(new Error(`Local file not found: ${localPath}`));
        return;
      }

      this.conn.sftp((err, sftp) => {
        if (err) {
          reject(err);
          return;
        }

        sftp.fastPut(localPath, remotePath, (err) => {
          if (err) {
            reject(err);
          } else {
            resolve(`File uploaded successfully to ${remotePath}`);
          }
          sftp.end();
        });
      });
    });
  }

  downloadFile(remotePath, localPath) {
    return new Promise((resolve, reject) => {
      this.conn.sftp((err, sftp) => {
        if (err) {
          reject(err);
          return;
        }

        sftp.fastGet(remotePath, localPath, (err) => {
          if (err) {
            reject(err);
          } else {
            resolve(`File downloaded successfully to ${localPath}`);
          }
          sftp.end();
        });
      });
    });
  }

  listFiles(path) {
    return this.executeCommand(`ls -la ${path}`);
  }

  sendResponse(response) {
    console.log(JSON.stringify(response));
  }

  sendError(id, code, message) {
    this.sendResponse({
      jsonrpc: "2.0",
      id: id,
      error: {
        code: code,
        message: message
      }
    });
  }
}

// Start the server
const server = new MCPSSHServer();

// Handle process termination
process.on('SIGINT', () => {
  if (server.conn) {
    server.conn.end();
  }
  process.exit(0);
});

process.on('SIGTERM', () => {
  if (server.conn) {
    server.conn.end();
  }
  process.exit(0);
});
