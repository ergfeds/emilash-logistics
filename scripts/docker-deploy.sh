#!/bin/bash

# Docker Deployment Script for Emilash Logistics
# This script builds and runs the application using Docker

set -e

echo "🐳 Docker Deployment Script for Emilash Logistics"
echo "==============================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker first:"
    echo "Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if docker-compose is available
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "❌ Docker Compose not found. Please install Docker Compose."
    exit 1
fi

echo "📦 Using $COMPOSE_CMD for orchestration"

# Create Dockerfile if it doesn't exist
if [ ! -f "Dockerfile" ]; then
    echo "📝 Creating Dockerfile..."
    cat > Dockerfile << 'EOF'
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

# Change ownership of the app directory
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Start the application
CMD ["npm", "start"]
EOF
fi

# Create docker-compose.yml if it doesn't exist
if [ ! -f "docker-compose.yml" ]; then
    echo "📝 Creating docker-compose.yml..."
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_USER=emilash
      - DB_PASSWORD=emilash_password
      - DB_NAME=emilash_shipping
      - MIGRATE_ON_START=1
      - SESSION_SECRET=your_secure_session_secret_change_this
      - COMPANY_NAME=Emilash Logistics
      - COMPANY_EMAIL=support@emilashlogistics.com
      - COMPANY_PHONE=+1-555-EMILASH
      - SITE_BASE_URL=http://localhost:3000
    depends_on:
      mysql:
        condition: service_healthy
    restart: unless-stopped
    volumes:
      - ./img:/app/img:ro

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=root_password
      - MYSQL_DATABASE=emilash_shipping
      - MYSQL_USER=emilash
      - MYSQL_PASSWORD=emilash_password
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
      - ./src/migrations:/docker-entrypoint-initdb.d:ro
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      timeout: 20s
      retries: 10

volumes:
  mysql_data:
EOF
fi

# Create .dockerignore if it doesn't exist
if [ ! -f ".dockerignore" ]; then
    echo "📝 Creating .dockerignore..."
    cat > .dockerignore << 'EOF'
node_modules
npm-debug.log
.git
.gitignore
README.md
.env
.env.*
.nyc_output
coverage
.DS_Store
*.log
EOF
fi

# Build and start services
echo "🔨 Building Docker images..."
$COMPOSE_CMD build

echo "🚀 Starting services..."
$COMPOSE_CMD up -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are running
echo "🔍 Checking service status..."
$COMPOSE_CMD ps

echo "✅ Docker deployment completed!"
echo "📱 Your application is available at: http://localhost:3000"
echo "🔧 Admin panel: http://localhost:3000/admin/login"
echo "📋 Default login: admin@emilash.local / admin123"
echo "⚠️  Remember to change the default admin password!"

echo ""
echo "📊 Useful Docker commands:"
echo "  $COMPOSE_CMD logs -f        - View application logs"
echo "  $COMPOSE_CMD ps             - Check service status"
echo "  $COMPOSE_CMD down           - Stop all services"
echo "  $COMPOSE_CMD exec app bash  - Access app container"
echo "  docker system prune         - Clean up unused Docker resources"