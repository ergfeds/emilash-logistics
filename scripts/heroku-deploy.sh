#!/bin/bash

# Heroku Deployment Script for Emilash Logistics
# This script helps deploy the application to Heroku

set -e

echo "🟣 Heroku Deployment Script for Emilash Logistics"
echo "==============================================="

# Check if Heroku CLI is installed
if ! command -v heroku &> /dev/null; then
    echo "❌ Heroku CLI not found. Please install it first:"
    echo "Visit: https://devcenter.heroku.com/articles/heroku-cli"
    exit 1
fi

# Login to Heroku (if not already logged in)
echo "🔐 Checking Heroku authentication..."
if ! heroku auth:whoami &> /dev/null; then
    echo "Please login to Heroku:"
    heroku login
fi

# Get app name from user or generate one
read -p "Enter Heroku app name (or press Enter for auto-generated): " APP_NAME

if [ -z "$APP_NAME" ]; then
    APP_NAME="emilash-logistics-$(date +%s)"
    echo "Using auto-generated app name: $APP_NAME"
fi

# Create Heroku app
echo "📦 Creating Heroku app: $APP_NAME"
if heroku apps:info $APP_NAME &> /dev/null; then
    echo "App $APP_NAME already exists, using existing app..."
else
    heroku create $APP_NAME
fi

# Add MySQL database (ClearDB or JawsDB)
echo "🗄️ Adding MySQL database..."
if heroku addons:info cleardb:ignite -a $APP_NAME &> /dev/null; then
    echo "ClearDB already added"
else
    echo "Adding ClearDB MySQL addon..."
    heroku addons:create cleardb:ignite -a $APP_NAME
fi

# Get database URL and parse it
echo "⚙️ Configuring database connection..."
DATABASE_URL=$(heroku config:get CLEARDB_DATABASE_URL -a $APP_NAME)

if [ -n "$DATABASE_URL" ]; then
    # Parse the database URL
    DB_USER=$(echo $DATABASE_URL | sed 's/mysql:\/\/\([^:]*\):.*/\1/')
    DB_PASSWORD=$(echo $DATABASE_URL | sed 's/mysql:\/\/[^:]*:\([^@]*\)@.*/\1/')
    DB_HOST=$(echo $DATABASE_URL | sed 's/mysql:\/\/[^@]*@\([^:\/]*\).*/\1/')
    DB_NAME=$(echo $DATABASE_URL | sed 's/.*\/\([^?]*\).*/\1/')
    
    # Set individual database config vars
    heroku config:set DB_HOST=$DB_HOST -a $APP_NAME
    heroku config:set DB_USER=$DB_USER -a $APP_NAME
    heroku config:set DB_PASSWORD=$DB_PASSWORD -a $APP_NAME
    heroku config:set DB_NAME=$DB_NAME -a $APP_NAME
    heroku config:set DB_PORT=3306 -a $APP_NAME
fi

# Set other environment variables
echo "🔧 Setting environment variables..."
heroku config:set NODE_ENV=production -a $APP_NAME
heroku config:set MIGRATE_ON_START=1 -a $APP_NAME
heroku config:set SESSION_SECRET=$(openssl rand -base64 32) -a $APP_NAME
heroku config:set SITE_BASE_URL=https://$APP_NAME.herokuapp.com -a $APP_NAME

# Set company information (you can customize these)
heroku config:set COMPANY_NAME="Emilash Logistics" -a $APP_NAME
heroku config:set COMPANY_EMAIL="support@emilashlogistics.com" -a $APP_NAME
heroku config:set COMPANY_PHONE="+1-555-EMILASH" -a $APP_NAME
heroku config:set COMPANY_WEBSITE="https://$APP_NAME.herokuapp.com" -a $APP_NAME

# Initialize git repository if not exists
if [ ! -d ".git" ]; then
    echo "📝 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit for Heroku deployment"
fi

# Add Heroku remote
echo "🔗 Adding Heroku remote..."
if git remote get-url heroku &> /dev/null; then
    git remote set-url heroku https://git.heroku.com/$APP_NAME.git
else
    git remote add heroku https://git.heroku.com/$APP_NAME.git
fi

# Deploy to Heroku
echo "🚀 Deploying to Heroku..."
git add .
git commit -m "Deploy to Heroku" || echo "No changes to commit"
git push heroku main || git push heroku master

# Run database migrations
echo "🗄️ Running database migrations..."
heroku run node deploy.js db -a $APP_NAME

echo "✅ Deployment completed!"
echo "📱 Your application is available at: https://$APP_NAME.herokuapp.com"
echo "🔧 Admin panel: https://$APP_NAME.herokuapp.com/admin/login"
echo "📋 Default login: admin@emilash.local / admin123"
echo "⚠️  Remember to change the default admin password!"

echo ""
echo "📊 Useful Heroku commands:"
echo "  heroku logs --tail -a $APP_NAME     - View application logs"
echo "  heroku ps -a $APP_NAME             - Check dyno status"
echo "  heroku config -a $APP_NAME         - View environment variables"
echo "  heroku run bash -a $APP_NAME       - Access app shell"