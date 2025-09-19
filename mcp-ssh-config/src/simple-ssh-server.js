#!/usr/bin/env node
const { Client } = require('ssh2');
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const readline = require('readline');

// Create Express app for REST API
const app = express();
app.use(cors());
app.use(express.json());

// Store SSH connections
const connections = new Map();

// Server configuration
const PORT = process.env.SSH_SERVER_PORT || 3000;

// Connection details for your Linux server
const DEFAULT_CONNECTION = {
    host: '10.20.17.38',
    port: 22,
    username: 'user1',
    password: 'g0]5(H0?'
};

// Connect endpoint
app.post('/connect', (req, res) => {
    const { id = 'default', host, port, username, password } = req.body;
    
    if (connections.has(id)) {
        return res.json({ 
            success: false, 
            message: `Connection ${id} already exists` 
        });
    }
    
    const conn = new Client();
    const config = host ? req.body : DEFAULT_CONNECTION;
    
    conn.on('ready', () => {
        connections.set(id, conn);
        res.json({ 
            success: true, 
            message: `Connected to ${config.host}:${config.port}` 
        });
    });
    
    conn.on('error', (err) => {
        res.json({ 
            success: false, 
            message: `Connection failed: ${err.message}` 
        });
    });
    
    conn.connect(config);
});

// Execute command endpoint
app.post('/execute', (req, res) => {
    const { id = 'default', command } = req.body;
    
    const conn = connections.get(id);
    if (!conn) {
        return res.json({ 
            success: false, 
            message: `No connection found with ID: ${id}` 
        });
    }
    
    conn.exec(command, (err, stream) => {
        if (err) {
            return res.json({ 
                success: false, 
                message: `Command failed: ${err.message}` 
            });
        }
        
        let output = '';
        let errorOutput = '';
        
        stream.on('close', (code) => {
            res.json({
                success: true,
                output: output,
                error: errorOutput,
                exitCode: code
            });
        });
        
        stream.on('data', (data) => {
            output += data.toString();
        });
        
        stream.stderr.on('data', (data) => {
            errorOutput += data.toString();
        });
    });
});

// Disconnect endpoint
app.post('/disconnect', (req, res) => {
    const { id = 'default' } = req.body;
    
    const conn = connections.get(id);
    if (!conn) {
        return res.json({ 
            success: false, 
            message: `No connection found with ID: ${id}` 
        });
    }
    
    conn.end();
    connections.delete(id);
    
    res.json({ 
        success: true, 
        message: `Disconnected from ${id}` 
    });
});

// Status endpoint
app.get('/status/:id?', (req, res) => {
    const id = req.params.id || 'default';
    const isConnected = connections.has(id);
    
    res.json({
        id: id,
        connected: isConnected,
        serverDetails: isConnected ? {
            host: DEFAULT_CONNECTION.host,
            username: DEFAULT_CONNECTION.username
        } : null
    });
});

// List connections
app.get('/connections', (req, res) => {
    const conns = Array.from(connections.keys());
    res.json({
        connections: conns,
        count: conns.length
    });
});

// CLI Interface for Cursor
if (process.argv.includes('--cli')) {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });
    
    // Auto-connect to default server
    const defaultConn = new Client();
    defaultConn.on('ready', () => {
        connections.set('default', defaultConn);
        console.log('Connected to Linux server');
    });
    defaultConn.on('error', (err) => {
        console.error('Connection error:', err.message);
    });
    defaultConn.connect(DEFAULT_CONNECTION);
    
    rl.on('line', (input) => {
        const conn = connections.get('default');
        if (!conn) {
            console.log('Not connected to server');
            return;
        }
        
        conn.exec(input, (err, stream) => {
            if (err) {
                console.error('Command error:', err.message);
                return;
            }
            
            stream.on('data', (data) => {
                process.stdout.write(data);
            });
            
            stream.stderr.on('data', (data) => {
                process.stderr.write(data);
            });
            
            stream.on('close', () => {
                console.log(''); // New line after output
            });
        });
    });
    
    process.on('SIGINT', () => {
        connections.forEach(conn => conn.end());
        process.exit(0);
    });
} else {
    // Start REST API server
    app.listen(PORT, () => {
        console.log(`SSH Server running on http://localhost:${PORT}`);
        console.log(`Default server: ${DEFAULT_CONNECTION.host}`);
        console.log('\nEndpoints:');
        console.log('  POST /connect    - Connect to SSH server');
        console.log('  POST /execute    - Execute command');
        console.log('  POST /disconnect - Disconnect from server');
        console.log('  GET  /status     - Check connection status');
        console.log('  GET  /connections - List all connections');
    });
}

// Clean up on exit
process.on('SIGINT', () => {
    connections.forEach(conn => conn.end());
    process.exit(0);
});
