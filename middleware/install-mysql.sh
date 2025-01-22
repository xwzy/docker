#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run this script with sudo"
    exit 1
fi

# Load credentials
source $(dirname "$0")/credentials.env

# Create data directory if not exists
mkdir -p /data/mysql

# Run MySQL container
docker run -d \
    --name mysql \
    --restart always \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
    -v /data/mysql:/var/lib/mysql \
    mysql:8.4

echo "MySQL 8.4 has been installed and configured:"
echo "- Port: 3306"
echo "- Username: root"
echo "- Password: $MYSQL_ROOT_PASSWORD"
echo "- Data directory: /data/mysql"
