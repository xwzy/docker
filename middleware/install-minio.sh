#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Load credentials
source $(dirname "$0")/credentials.env

# Create data directory if not exists
mkdir -p /data/minio

# Set proper permissions
chown -R $SUDO_USER:$SUDO_USER /data/minio

# Stop and remove existing container if exists
docker stop minio >/dev/null 2>&1
docker rm minio >/dev/null 2>&1

# Run MinIO container with debug output
docker run -d \
    --name minio \
    --restart always \
    -p 9000:9000 \
    -p 9001:9001 \
    -e "MINIO_ROOT_USER=$MINIO_ROOT_USER" \
    -e "MINIO_ROOT_PASSWORD=$MINIO_ROOT_PASSWORD" \
    -v /data/minio:/data \
    minio/minio server --console-address ":9001" /data

echo "MinIO has been installed and configured:"
echo "- API Port: 9000"
echo "- Console Port: 9001"
echo "- Username: $MINIO_ROOT_USER"
echo "- Password: $MINIO_ROOT_PASSWORD"
echo "- Data directory: /data/minio" 