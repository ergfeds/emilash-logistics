# 🚀 Emilash Logistics - Deployment Guide

This comprehensive guide covers deploying the Emilash Logistics shipping management system to various platforms.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Configuration](#environment-configuration)
3. [Local Development Setup](#local-development-setup)
4. [Production Deployment Options](#production-deployment-options)
   - [Railway Deployment](#railway-deployment)
   - [Heroku Deployment](#heroku-deployment)
   - [Docker Deployment](#docker-deployment)
   - [VPS/Server Deployment](#vpsserver-deployment)
5. [Database Setup](#database-setup)
6. [Post-Deployment Steps](#post-deployment-steps)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

- **Node.js** 18+ installed
- **MySQL** 8.0+ database (local or remote)
- **Git** for version control
- **npm** or **yarn** package manager

## Environment Configuration

### 1. Create Environment File

Copy the production template and customize:

```bash
cp .env.production .env
```

### 2. Configure Database Settings

Edit `.env` with your database credentials:

```env
# Database Configuration
DB_HOST=your_database_host
DB_PORT=3306
DB_USER=your_database_user
DB_PASSWORD=your_database_password
DB_NAME=your_database_name

# Security
SESSION_SECRET=your_super_secure_session_secret_change_this
NODE_ENV=production

# Company Information
COMPANY_NAME=Your Company Name
COMPANY_EMAIL=support@yourcompany.com
COMPANY_PHONE=+1-555-YOUR-PHONE
SITE_BASE_URL=https://yourdomain.com
```

### 3. SMTP Configuration (Optional)

For email notifications:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your_email@gmail.com
SMTP_PASSWORD=your_app_password
SMTP_FROM="Your Company" <no-reply@yourcompany.com>
```

## Local Development Setup

### Quick Start

```bash
# Install dependencies
npm install

# Set up database and run migrations
npm run deploy:db

# Start development server
npm run dev
```

### Manual Setup

```bash
# 1. Install dependencies
npm install

# 2. Configure environment
cp .env.production .env
# Edit .env with your settings

# 3. Test database connection
npm run deploy:check

# 4. Run database migrations
npm run migrate

# 5. Start the server
npm start
```

Access the application:
- **Frontend**: http://localhost:3000
- **Admin Panel**: http://localhost:3000/admin/login
- **Default Login**: admin@emilash.local / admin123

## Production Deployment Options

### Railway Deployment

**Railway** is a modern deployment platform with excellent Node.js support.

#### Prerequisites
- Railway account (https://railway.app)
- Railway CLI installed: `npm install -g @railway/cli`

#### Deployment Steps

```bash
# 1. Login to Railway
railway login

# 2. Run deployment script
chmod +x scripts/railway-deploy.sh
./scripts/railway-deploy.sh
```

#### Manual Railway Setup

```bash
# 1. Initialize Railway project
railway init

# 2. Add MySQL database
railway add --database mysql

# 3. Set environment variables
railway variables set NODE_ENV=production
railway variables set MIGRATE_ON_START=1
railway variables set SESSION_SECRET=$(openssl rand -base64 32)

# 4. Deploy
railway up
```

### Heroku Deployment

**Heroku** is a popular cloud platform with extensive add-on ecosystem.

#### Prerequisites
- Heroku account (https://heroku.com)
- Heroku CLI installed

#### Deployment Steps

```bash
# 1. Login to Heroku
heroku login

# 2. Run deployment script
chmod +x scripts/heroku-deploy.sh
./scripts/heroku-deploy.sh
```

#### Manual Heroku Setup

```bash
# 1. Create Heroku app
heroku create your-app-name

# 2. Add MySQL database (ClearDB)
heroku addons:create cleardb:ignite

# 3. Configure environment
heroku config:set NODE_ENV=production
heroku config:set MIGRATE_ON_START=1
heroku config:set SESSION_SECRET=$(openssl rand -base64 32)

# 4. Deploy
git push heroku main

# 5. Run migrations
heroku run npm run migrate
```

### Docker Deployment

**Docker** provides containerized deployment for any environment.

#### Prerequisites
- Docker and Docker Compose installed

#### Deployment Steps

```bash
# 1. Run Docker deployment script
chmod +x scripts/docker-deploy.sh
./scripts/docker-deploy.sh
```

#### Manual Docker Setup

```bash
# 1. Build and start services
docker-compose up -d

# 2. Check status
docker-compose ps

# 3. View logs
docker-compose logs -f
```

### VPS/Server Deployment

**VPS deployment** for dedicated servers or cloud instances.

#### Prerequisites
- Ubuntu/CentOS server with root access
- Domain name (optional)
- SSL certificate (recommended)

#### Server Setup

```bash
# 1. Update system
sudo apt update && sudo apt upgrade -y

# 2. Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 3. Install MySQL
sudo apt install mysql-server -y
sudo mysql_secure_installation

# 4. Install PM2 (Process Manager)
sudo npm install -g pm2

# 5. Clone repository
git clone <your-repo-url>
cd emilash-shipping-site

# 6. Install dependencies
npm install

# 7. Configure environment
cp .env.production .env
# Edit .env with your settings

# 8. Run database setup
npm run deploy:db

# 9. Start with PM2
pm2 start src/server.js --name "emilash-logistics"
pm2 startup
pm2 save
```

#### Nginx Configuration (Optional)

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Database Setup

### Supported Database Providers

1. **Railway MySQL** - Managed MySQL with automatic backups
2. **Heroku ClearDB** - MySQL add-on for Heroku
3. **PlanetScale** - Serverless MySQL platform
4. **AWS RDS** - Amazon's managed database service
5. **Google Cloud SQL** - Google's managed MySQL
6. **Self-hosted MySQL** - Your own MySQL server

### Database Migration Commands

```bash
# Test database connection
npm run deploy:check

# Run full migration
npm run migrate

# Reset database (caution!)
node migrate-database.js reset

# Test migration
node migrate-database.js test
```

### Manual Database Setup

If automatic migration fails:

```sql
-- 1. Create database
CREATE DATABASE emilash_shipping CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. Create user (if needed)
CREATE USER 'emilash'@'%' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON emilash_shipping.* TO 'emilash'@'%';
FLUSH PRIVILEGES;

-- 3. Run migration file
-- Execute src/migrations/init.sql in your MySQL client
```

## Post-Deployment Steps

### 1. Verify Deployment

```bash
# Check application health
curl https://yourdomain.com/

# Test admin login
# Visit: https://yourdomain.com/admin/login
# Login: admin@emilash.local / admin123
```

### 2. Security Configuration

**⚠️ IMPORTANT: Change default admin password immediately!**

1. Login to admin panel
2. Go to Users section
3. Edit Administrator user
4. Change password to a secure one
5. Update email address

### 3. Company Configuration

1. Go to Settings in admin panel
2. Update company information:
   - Company name
   - Contact details
   - SMTP settings (for email notifications)
   - Site base URL

### 4. SSL Certificate (Production)

For HTTPS (recommended):

```bash
# Using Certbot (Let's Encrypt)
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com
```

### 5. Monitoring Setup

```bash
# PM2 monitoring (for VPS)
pm2 monit

# Set up log rotation
pm2 install pm2-logrotate
```

## Troubleshooting

### Common Issues

#### Database Connection Failed

```bash
# Check database credentials
npm run deploy:check

# Test connection manually
node -e "require('./src/config/db').getPool().query('SELECT 1').then(() => console.log('OK')).catch(console.error)"
```

#### Migration Errors

```bash
# Check migration status
node migrate-database.js test

# Reset and retry
node migrate-database.js reset
```

#### Port Already in Use

```bash
# Find process using port 3000
lsof -i :3000

# Kill process
kill -9 <PID>

# Or use different port
PORT=3001 npm start
```

#### Permission Denied

```bash
# Fix file permissions
chmod +x scripts/*.sh
chmod +x *.js

# Fix ownership (if needed)
sudo chown -R $USER:$USER .
```

### Environment-Specific Issues

#### Railway
- Check Railway dashboard for build logs
- Verify environment variables are set
- Ensure database service is running

#### Heroku
- Check Heroku logs: `heroku logs --tail`
- Verify add-ons are provisioned
- Check dyno status: `heroku ps`

#### Docker
- Check container logs: `docker-compose logs`
- Verify services are healthy: `docker-compose ps`
- Restart services: `docker-compose restart`

### Getting Help

1. **Check Logs**: Always check application logs first
2. **Environment Variables**: Verify all required variables are set
3. **Database Connection**: Test database connectivity
4. **Network Issues**: Check firewall and security groups
5. **Resource Limits**: Ensure sufficient memory/CPU

### Useful Commands

```bash
# Application logs
npm run dev  # Development with auto-reload
npm start    # Production start

# Database operations
npm run migrate     # Run migrations
npm run deploy:db   # Full database setup

# Deployment
npm run deploy         # Full deployment check
npm run deploy:check   # Environment validation
npm run deploy:validate # Deployment validation

# Process management (PM2)
pm2 list           # List processes
pm2 restart all    # Restart all processes
pm2 logs           # View logs
pm2 monit          # Monitor resources
```

---

## 🎉 Congratulations!

Your Emilash Logistics system is now deployed and ready to manage shipments!

### Next Steps:
1. 🔐 Change default admin password
2. ⚙️ Configure company settings
3. 📧 Set up SMTP for email notifications
4. 🚚 Start creating shipments
5. 📊 Monitor system performance

### Features Available:
- ✅ Complete shipment lifecycle management
- ✅ 15+ shipping statuses with workflow
- ✅ Live animal shipping support
- ✅ Multiple freight modes (Air/Sea/Land)
- ✅ Package classification and special handling
- ✅ Temperature control and health certificates
- ✅ Public tracking interface
- ✅ Admin dashboard with analytics
- ✅ User management with role-based access

For support and updates, check the project documentation and repository.