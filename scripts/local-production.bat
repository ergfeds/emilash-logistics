@echo off
REM Local Production Deployment Script for Windows
REM This script sets up the application for local production testing

echo 🏠 Local Production Setup for Emilash Logistics
echo ===============================================

REM Check if Node.js is installed
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Node.js not found. Please install Node.js first.
    echo Visit: https://nodejs.org/
    pause
    exit /b 1
)

REM Check if .env file exists
if not exist ".env" (
    echo ❌ .env file not found. Creating from template...
    copy ".env.production" ".env"
    echo ⚠️  Please edit .env file with your production settings before continuing.
    pause
    exit /b 1
)

echo 📦 Installing dependencies...
npm install
if %errorlevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo 🗄️ Setting up database...
node deploy.js db
if %errorlevel% neq 0 (
    echo ❌ Database setup failed
    pause
    exit /b 1
)

echo 🔍 Validating deployment...
node deploy.js validate
if %errorlevel% neq 0 (
    echo ❌ Deployment validation failed
    pause
    exit /b 1
)

echo ✅ Local production setup completed!
echo.
echo 🚀 Starting the server...
echo Press Ctrl+C to stop the server
echo.
echo 📱 Application will be available at: http://localhost:3000
echo 🔧 Admin panel: http://localhost:3000/admin/login
echo 📋 Default login: admin@emilash.local / admin123
echo.

REM Start the server
npm start