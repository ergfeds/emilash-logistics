#!/usr/bin/env node

/**
 * Deployment Script for Emilash Logistics
 * Handles database setup, migrations, and environment validation
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');
const { loadEnv } = require('./src/config/env');

// Load environment variables
loadEnv();

const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    magenta: '\x1b[35m',
    cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
    console.log(`${colors[color]}${message}${colors.reset}`);
}

function checkEnvironment() {
    log('🔍 Checking environment configuration...', 'cyan');
    
    const requiredVars = [
        'DB_HOST',
        'DB_USER', 
        'DB_NAME',
        'SESSION_SECRET'
    ];
    
    const missing = requiredVars.filter(varName => !process.env[varName]);
    
    if (missing.length > 0) {
        log(`❌ Missing required environment variables: ${missing.join(', ')}`, 'red');
        log('Please check your .env file and ensure all required variables are set.', 'yellow');
        process.exit(1);
    }
    
    log('✅ Environment configuration looks good!', 'green');
}

function installDependencies() {
    log('📦 Installing dependencies...', 'cyan');
    try {
        execSync('npm install', { stdio: 'inherit' });
        log('✅ Dependencies installed successfully!', 'green');
    } catch (error) {
        log('❌ Failed to install dependencies', 'red');
        process.exit(1);
    }
}

async function setupDatabase() {
    log('🗄️ Setting up database...', 'cyan');
    
    try {
        const { ensureDatabase, runMigrations, ensureDefaultAdmin } = require('./src/config/db');
        
        // Ensure database exists
        await ensureDatabase();
        log('✅ Database ensured', 'green');
        
        // Run migrations
        await runMigrations();
        log('✅ Database migrations completed', 'green');
        
        // Ensure default admin exists
        await ensureDefaultAdmin();
        log('✅ Default admin user ensured', 'green');
        
    } catch (error) {
        log(`❌ Database setup failed: ${error.message}`, 'red');
        process.exit(1);
    }
}

function validateDeployment() {
    log('🔍 Validating deployment...', 'cyan');
    
    // Check if server.js exists
    if (!fs.existsSync('./src/server.js')) {
        log('❌ server.js not found', 'red');
        process.exit(1);
    }
    
    // Check if package.json has start script
    const packageJson = JSON.parse(fs.readFileSync('./package.json', 'utf8'));
    if (!packageJson.scripts || !packageJson.scripts.start) {
        log('❌ No start script found in package.json', 'red');
        process.exit(1);
    }
    
    log('✅ Deployment validation passed!', 'green');
}

async function deploy() {
    log('🚀 Starting Emilash Logistics deployment...', 'bright');
    log('=' .repeat(50), 'cyan');
    
    try {
        checkEnvironment();
        installDependencies();
        await setupDatabase();
        validateDeployment();
        
        log('=' .repeat(50), 'cyan');
        log('🎉 Deployment completed successfully!', 'green');
        log('', 'reset');
        log('Next steps:', 'bright');
        log('1. Start the server: npm start', 'yellow');
        log('2. Access admin panel: http://localhost:3000/admin/login', 'yellow');
        log('3. Default login: admin@emilash.local / admin123', 'yellow');
        log('4. Change default admin password in production!', 'red');
        
    } catch (error) {
        log(`❌ Deployment failed: ${error.message}`, 'red');
        process.exit(1);
    }
}

// Handle command line arguments
const command = process.argv[2];

switch (command) {
    case 'check':
        checkEnvironment();
        break;
    case 'install':
        installDependencies();
        break;
    case 'db':
        setupDatabase();
        break;
    case 'validate':
        validateDeployment();
        break;
    default:
        deploy();
}

module.exports = { deploy, checkEnvironment, setupDatabase };