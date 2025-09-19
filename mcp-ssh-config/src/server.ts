#!/usr/bin/env node
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { Client as SSHClient } from 'ssh2';
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { dirname, join } from 'path';
import { promisify } from 'util';

// Store SSH connections
const connections = new Map<string, SSHClient>();

// Create MCP server
const server = new Server(
  {
    name: 'mcp-ssh-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Define the tools
server.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'ssh_connect',
      description: 'Connect to an SSH server',
      inputSchema: {
        type: 'object',
        properties: {
          id: {
            type: 'string',
            description: 'Unique connection identifier',
          },
          host: {
            type: 'string',
            description: 'SSH server hostname or IP address',
          },
          port: {
            type: 'number',
            description: 'SSH server port (default: 22)',
            default: 22,
          },
          username: {
            type: 'string',
            description: 'SSH username',
          },
          password: {
            type: 'string',
            description: 'SSH password (for password authentication)',
          },
          privateKey: {
            type: 'string',
            description: 'Private key content (for key authentication)',
          },
          passphrase: {
            type: 'string',
            description: 'Passphrase for encrypted private key',
          },
        },
        required: ['id', 'host', 'username'],
      },
    },
    {
      name: 'ssh_execute',
      description: 'Execute a command on the SSH server',
      inputSchema: {
        type: 'object',
        properties: {
          id: {
            type: 'string',
            description: 'Connection identifier',
          },
          command: {
            type: 'string',
            description: 'Command to execute',
          },
          cwd: {
            type: 'string',
            description: 'Working directory for the command',
          },
        },
        required: ['id', 'command'],
      },
    },
    {
      name: 'ssh_disconnect',
      description: 'Disconnect from an SSH server',
      inputSchema: {
        type: 'object',
        properties: {
          id: {
            type: 'string',
            description: 'Connection identifier',
          },
        },
        required: ['id'],
      },
    },
    {
      name: 'ssh_upload',
      description: 'Upload a file to the SSH server',
      inputSchema: {
        type: 'object',
        properties: {
          id: {
            type: 'string',
            description: 'Connection identifier',
          },
          localPath: {
            type: 'string',
            description: 'Local file path',
          },
          remotePath: {
            type: 'string',
            description: 'Remote file path',
          },
        },
        required: ['id', 'localPath', 'remotePath'],
      },
    },
    {
      name: 'ssh_download',
      description: 'Download a file from the SSH server',
      inputSchema: {
        type: 'object',
        properties: {
          id: {
            type: 'string',
            description: 'Connection identifier',
          },
          remotePath: {
            type: 'string',
            description: 'Remote file path',
          },
          localPath: {
            type: 'string',
            description: 'Local file path',
          },
        },
        required: ['id', 'remotePath', 'localPath'],
      },
    },
    {
      name: 'ssh_list_dir',
      description: 'List directory contents on the SSH server',
      inputSchema: {
        type: 'object',
        properties: {
          id: {
            type: 'string',
            description: 'Connection identifier',
          },
          path: {
            type: 'string',
            description: 'Directory path to list',
            default: '.',
          },
        },
        required: ['id'],
      },
    },
  ],
}));

// Handle tool calls
server.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'ssh_connect': {
      const { id, host, port = 22, username, password, privateKey, passphrase } = args as any;
      
      // Check if connection already exists
      if (connections.has(id)) {
        return {
          content: [
            {
              type: 'text',
              text: `Connection ${id} already exists. Disconnect first or use a different ID.`,
            },
          ],
        };
      }

      const client = new SSHClient();
      
      return new Promise((resolve) => {
        client.on('ready', () => {
          connections.set(id, client);
          resolve({
            content: [
              {
                type: 'text',
                text: `Successfully connected to ${host}:${port} as ${username}`,
              },
            ],
          });
        });

        client.on('error', (err) => {
          resolve({
            content: [
              {
                type: 'text',
                text: `Connection failed: ${err.message}`,
              },
            ],
          });
        });

        const config: any = {
          host,
          port,
          username,
        };

        if (password) {
          config.password = password;
        } else if (privateKey) {
          config.privateKey = privateKey;
          if (passphrase) {
            config.passphrase = passphrase;
          }
        }

        client.connect(config);
      });
    }

    case 'ssh_execute': {
      const { id, command, cwd } = args as any;
      
      const client = connections.get(id);
      if (!client) {
        return {
          content: [
            {
              type: 'text',
              text: `No connection found with ID: ${id}`,
            },
          ],
        };
      }

      return new Promise((resolve) => {
        const fullCommand = cwd ? `cd "${cwd}" && ${command}` : command;
        
        client.exec(fullCommand, (err, stream) => {
          if (err) {
            resolve({
              content: [
                {
                  type: 'text',
                  text: `Command execution failed: ${err.message}`,
                },
              ],
            });
            return;
          }

          let output = '';
          let errorOutput = '';

          stream.on('close', (code: number) => {
            resolve({
              content: [
                {
                  type: 'text',
                  text: `Command output:\n${output}${errorOutput ? '\n\nErrors:\n' + errorOutput : ''}\n\nExit code: ${code}`,
                },
              ],
            });
          });

          stream.on('data', (data: Buffer) => {
            output += data.toString();
          });

          stream.stderr.on('data', (data: Buffer) => {
            errorOutput += data.toString();
          });
        });
      });
    }

    case 'ssh_disconnect': {
      const { id } = args as any;
      
      const client = connections.get(id);
      if (!client) {
        return {
          content: [
            {
              type: 'text',
              text: `No connection found with ID: ${id}`,
            },
          ],
        };
      }

      client.end();
      connections.delete(id);
      
      return {
        content: [
          {
            type: 'text',
            text: `Disconnected from ${id}`,
          },
        ],
      };
    }

    case 'ssh_upload': {
      const { id, localPath, remotePath } = args as any;
      
      const client = connections.get(id);
      if (!client) {
        return {
          content: [
            {
              type: 'text',
              text: `No connection found with ID: ${id}`,
            },
          ],
        };
      }

      return new Promise((resolve) => {
        client.sftp((err, sftp) => {
          if (err) {
            resolve({
              content: [
                {
                  type: 'text',
                  text: `SFTP connection failed: ${err.message}`,
                },
              ],
            });
            return;
          }

          const localContent = readFileSync(localPath);
          
          sftp.writeFile(remotePath, localContent, (err) => {
            if (err) {
              resolve({
                content: [
                  {
                    type: 'text',
                    text: `Upload failed: ${err.message}`,
                  },
                ],
              });
            } else {
              resolve({
                content: [
                  {
                    type: 'text',
                    text: `Successfully uploaded ${localPath} to ${remotePath}`,
                  },
                ],
              });
            }
            sftp.end();
          });
        });
      });
    }

    case 'ssh_download': {
      const { id, remotePath, localPath } = args as any;
      
      const client = connections.get(id);
      if (!client) {
        return {
          content: [
            {
              type: 'text',
              text: `No connection found with ID: ${id}`,
            },
          ],
        };
      }

      return new Promise((resolve) => {
        client.sftp((err, sftp) => {
          if (err) {
            resolve({
              content: [
                {
                  type: 'text',
                  text: `SFTP connection failed: ${err.message}`,
                },
              ],
            });
            return;
          }

          sftp.readFile(remotePath, (err, data) => {
            if (err) {
              resolve({
                content: [
                  {
                    type: 'text',
                    text: `Download failed: ${err.message}`,
                  },
                ],
              });
            } else {
              // Ensure directory exists
              const dir = dirname(localPath);
              if (!existsSync(dir)) {
                mkdirSync(dir, { recursive: true });
              }
              
              writeFileSync(localPath, data);
              resolve({
                content: [
                  {
                    type: 'text',
                    text: `Successfully downloaded ${remotePath} to ${localPath}`,
                  },
                ],
              });
            }
            sftp.end();
          });
        });
      });
    }

    case 'ssh_list_dir': {
      const { id, path = '.' } = args as any;
      
      const client = connections.get(id);
      if (!client) {
        return {
          content: [
            {
              type: 'text',
              text: `No connection found with ID: ${id}`,
            },
          ],
        };
      }

      return new Promise((resolve) => {
        client.exec(`ls -la "${path}"`, (err, stream) => {
          if (err) {
            resolve({
              content: [
                {
                  type: 'text',
                  text: `Directory listing failed: ${err.message}`,
                },
              ],
            });
            return;
          }

          let output = '';
          let errorOutput = '';

          stream.on('close', () => {
            if (errorOutput) {
              resolve({
                content: [
                  {
                    type: 'text',
                    text: `Error: ${errorOutput}`,
                  },
                ],
              });
            } else {
              resolve({
                content: [
                  {
                    type: 'text',
                    text: `Directory listing for ${path}:\n${output}`,
                  },
                ],
              });
            }
          });

          stream.on('data', (data: Buffer) => {
            output += data.toString();
          });

          stream.stderr.on('data', (data: Buffer) => {
            errorOutput += data.toString();
          });
        });
      });
    }

    default:
      return {
        content: [
          {
            type: 'text',
            text: `Unknown tool: ${name}`,
          },
        ],
      };
  }
});

// Clean up connections on exit
process.on('SIGINT', () => {
  connections.forEach((client) => client.end());
  process.exit(0);
});

// Start the server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('MCP SSH Server started');
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
