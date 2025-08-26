#!/bin/bash

# Railway Deployment Script for Emilash Logistics
# This script helps deploy the application to Railway

set -e

echo "🚂 Railway Deployment Script for Emilash Logistics"
echo "================================================="

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Please install it first:"
    echo "npm install -g @railway/cli"
    exit 1
fi

# Login to Railway (if not already logged in)
echo "🔐 Checking Railway authentication..."
if ! railway whoami &> /dev/null; then
    echo "Please login to Railway:"
    railway login
fi

# Create new Railway project or link existing one
echo "📦 Setting up Railway project..."
if [ ! -f "railway.toml" ]; then
    echo "Creating new Railway project..."
    railway init
else
    echo "Using existing Railway configuration..."
fi

# Add MySQL database service
echo "🗄️ Adding MySQL database..."
railway add --database mysql

# Set environment variables
echo "⚙️ Setting environment variables..."
railway variables set NODE_ENV=production
railway variables set MIGRATE_ON_START=1
railway variables set SESSION_SECRET=$(openssl rand -base64 32)

# Deploy the application
echo "🚀 Deploying to Railway..."
railway up

# Get the deployment URL
echo "🌐 Getting deployment URL..."
DEPLOY_URL=$(railway status --json | jq -r '.deployments[0].url')

echo "✅ Deployment completed!"
echo "📱 Your application is available at: $DEPLOY_URL"
echo "🔧 Admin panel: $DEPLOY_URL/admin/login"
echo "📋 Default login: admin@emilash.local / admin123"
echo "⚠️  Remember to change the default admin password!"

echo ""
echo "📊 Useful Railway commands:"
echo "  railway logs        - View application logs"
echo "  railway status      - Check deployment status"
echo "  railway variables   - Manage environment variables"
echo "  railway connect     - Connect to database"