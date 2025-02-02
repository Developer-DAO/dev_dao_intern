#!/bin/bash

# Make script exit on first error
set -e

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo "Error: .env.production file not found!"
    echo "Please create it from .env.production.example"
    exit 1
fi

# Create necessary directories
mkdir -p nginx
mkdir -p ssl
mkdir -p certbot/conf
mkdir -p certbot/www

# Check if running on the server for the first time
if [ ! -d "/etc/letsencrypt/live/${DOMAIN}" ]; then
    echo "Initial setup detected. Setting up SSL certificates..."

    # Start nginx with temporary config for SSL setup
    docker-compose -f docker-compose.prod.yml up -d nginx

    # Get SSL certificate
    docker-compose -f docker-compose.prod.yml run --rm certbot

    # Stop services
    docker-compose -f docker-compose.prod.yml down
fi

# Deploy the application
echo "Deploying application..."
docker-compose -f docker-compose.prod.yml up -d

# Check if services are running
echo "Checking service health..."
docker-compose -f docker-compose.prod.yml ps

echo "Deployment completed! Your application should be running at https://${DOMAIN}"
echo "Check the logs with: docker-compose -f docker-compose.prod.yml logs -f"