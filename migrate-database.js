#!/usr/bin/env node

/**
 * Database Migration Script for Emilash Logistics
 * Uses environment variables for database configuration
 */

const { loadEnv } = require('./src/config/env');
const { ensureDatabase, runMigrations, ensureDefaultAdmin, getPool } = require('./src/config/db');

// Load environment variables
loadEnv();

const colors = {
    reset: '\x1b[0m',
    bright: '\x1b[1m',
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    cyan: '\x1b[36m'
};

function log(message, color = 'reset') {
    console.log(`${colors[color]}${message}${colors.reset}`);
}

// Database configuration from environment variables
const DB_CONFIG = {
	host: process.env.DB_HOST || 'localhost',
	port: Number(process.env.DB_PORT || 3306),
	user: process.env.DB_USER || 'root',
	password: process.env.DB_PASSWORD || '',
	database: process.env.DB_NAME || 'emilash_shipping'
};

log('🚀 Starting Database Migration...', 'bright');
log(`📡 Connecting to: ${DB_CONFIG.host}:${DB_CONFIG.port}`, 'cyan');
log(`🗄️  Database: ${DB_CONFIG.database}`, 'cyan');
log('=' .repeat(50), 'cyan');

async function runMigration() {
	try {
		// Ensure database exists
		log('🏗️ Ensuring database exists...', 'cyan');
		await ensureDatabase();
		log('✅ Database ensured', 'green');
		
		// Run migrations using the existing function
		log('📋 Running database migrations...', 'cyan');
		await runMigrations();
		log('✅ Migrations completed', 'green');
		
		// Ensure default admin
		log('🔐 Setting up default admin user...', 'cyan');
		await ensureDefaultAdmin();
		log('✅ Default admin user ensured', 'green');
		log('   📧 Email: admin@emilash.local', 'yellow');
		log('   🔑 Password: admin123', 'yellow');
		
		// Verify database setup
		const pool = getPool();
		const [statusCount] = await pool.query('SELECT COUNT(*) as count FROM statuses');
		const [userCount] = await pool.query('SELECT COUNT(*) as count FROM users');
		const [tables] = await pool.query('SHOW TABLES');
		
		log('\n📊 Database Statistics:', 'bright');
		log(`   📋 Tables: ${tables.length}`, 'yellow');
		log(`   🏷️  Statuses: ${statusCount[0].count}`, 'yellow');
		log(`   👥 Users: ${userCount[0].count}`, 'yellow');
		
		log('\n🎉 Migration completed successfully!', 'green');
		log('🌐 Your Emilash Shipping System is ready to use', 'bright');
		log('\n📝 Features Available:', 'bright');
		log('   ✅ 15+ Shipping Statuses', 'green');
		log('   ✅ Live Animal Shipping', 'green');
		log('   ✅ Multiple Freight Modes (Air/Sea/Land)', 'green');
		log('   ✅ Package Type Classification', 'green');
		log('   ✅ Special Handling Requirements', 'green');
		log('   ✅ Temperature Control Options', 'green');
		log('   ✅ Health Certificate Tracking', 'green');
		
	} catch (error) {
		log(`❌ Migration failed: ${error.message}`, 'red');
		
		if (error.code === 'ER_ACCESS_DENIED_ERROR') {
			log('\n🔑 Authentication Error:', 'red');
			log('   - Check if the password is correct', 'yellow');
			log('   - Verify the database user has proper permissions', 'yellow');
			log('   - Ensure your IP is whitelisted on the MySQL server', 'yellow');
		} else if (error.code === 'ECONNREFUSED') {
			log('\n🌐 Connection Error:', 'red');
			log('   - Check if the MySQL server is running', 'yellow');
			log('   - Verify the host and port are correct', 'yellow');
			log('   - Check firewall settings', 'yellow');
		} else if (error.code === 'ENOTFOUND') {
			log('\n🌐 DNS Error:', 'red');
			log('   - Check if the database host is correct', 'yellow');
			log('   - Verify your internet connection', 'yellow');
		}
		
		process.exit(1);
	}
}

// Handle command line arguments
const command = process.argv[2];

switch (command) {
    case 'test':
        log('🔍 Testing database connection...', 'cyan');
        runMigration().then(() => {
            log('✅ Database test completed!', 'green');
            process.exit(0);
        }).catch(() => process.exit(1));
        break;
    case 'reset':
        log('⚠️ WARNING: This will reset the database!', 'red');
        runMigration().then(() => process.exit(0)).catch(() => process.exit(1));
        break;
    default:
        // Run the migration
        runMigration().then(() => process.exit(0)).catch(() => process.exit(1));
}

module.exports = { runMigration };
