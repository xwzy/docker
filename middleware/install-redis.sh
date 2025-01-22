#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Load credentials
source $(dirname "$0")/credentials.env

# Create data directory if not exists
mkdir -p /data/redis

# Set proper permissions
chown -R $SUDO_USER:$SUDO_USER /data/redis

# Run Redis container
docker run -d \
    --name redis \
    --restart always \
    -p 6379:6379 \
    -v /data/redis:/data \
    redis:7.4 \
    redis-server --requirepass $REDIS_PASSWORD

echo "Redis has been installed and configured:"
echo "- Port: 6379"
echo "- Password: $REDIS_PASSWORD"
echo "- Data directory: /data/redis" 