// Test script to verify SSH connection
const { Client } = require('ssh2');

const conn = new Client();

console.log('Testing SSH connection to 10.20.17.38...\n');

conn.on('ready', () => {
    console.log('✓ Connection successful!\n');
    
    // Test command execution
    conn.exec('whoami && hostname && uname -a', (err, stream) => {
        if (err) {
            console.error('✗ Command execution failed:', err.message);
            conn.end();
            return;
        }
        
        console.log('Server Information:');
        console.log('==================');
        
        let output = '';
        stream.on('data', (data) => {
            output += data.toString();
        });
        
        stream.on('close', () => {
            console.log(output);
            
            // Test disk info script if it exists
            console.log('\nTesting disk details script...');
            conn.exec('[ -f ~/get_disk_details.sh ] && echo "Script found" || echo "Script not found"', (err, stream) => {
                if (err) {
                    console.error('✗ Failed to check for script:', err.message);
                    conn.end();
                    return;
                }
                
                let scriptCheck = '';
                stream.on('data', (data) => {
                    scriptCheck += data.toString();
                });
                
                stream.on('close', () => {
                    console.log(scriptCheck.trim());
                    
                    if (scriptCheck.includes('Script found')) {
                        conn.exec('cd ~ && ./get_disk_details.sh 2>&1 | head -20', (err, stream) => {
                            if (err) {
                                console.error('✗ Failed to run disk details script:', err.message);
                                conn.end();
                                return;
                            }
                            
                            console.log('\nDisk Details Output (first 20 lines):');
                            console.log('=====================================');
                            
                            stream.on('data', (data) => {
                                process.stdout.write(data.toString());
                            });
                            
                            stream.stderr.on('data', (data) => {
                                process.stderr.write(data.toString());
                            });
                            
                            stream.on('close', () => {
                                console.log('\n✓ All tests completed successfully!');
                                conn.end();
                            });
                        });
                    } else {
                        console.log('\n✓ Connection tests completed successfully!');
                        console.log('Note: get_disk_details.sh script not found in home directory');
                        conn.end();
                    }
                });
            });
        });
    });
});

conn.on('error', (err) => {
    console.error('✗ Connection failed:', err.message);
    console.error('\nPlease check:');
    console.error('1. Server IP is correct (10.20.17.38)');
    console.error('2. SSH service is running on the server');
    console.error('3. Username and password are correct');
    console.error('4. Firewall allows SSH connections');
    process.exit(1);
});

// Connection configuration
const config = {
    host: '10.20.17.38',
    port: 22,
    username: 'user1',
    password: 'g0]5(H0?',
    readyTimeout: 10000
};

console.log(`Connecting to ${config.username}@${config.host}:${config.port}...`);
conn.connect(config);
