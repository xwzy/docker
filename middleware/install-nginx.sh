#!/bin/bash

# Check if script is run with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi

# Create required directories
mkdir -p /data/nginx/conf.d
mkdir -p /data/nginx/logs
mkdir -p /data/nginx/html

# Create default nginx.conf
cat > /data/nginx/nginx.conf <<EOF
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    keepalive_timeout  65;

    include /etc/nginx/conf.d/*.conf;
}
EOF

# Create default site config
cat > /data/nginx/conf.d/default.conf <<EOF
server {
    listen       80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF

# Create reload script
cat > /data/nginx/reload.sh <<EOF
#!/bin/bash
if [ "\$EUID" -ne 0 ]; then 
    echo "Please run with sudo"
    exit 1
fi
docker exec nginx nginx -t && docker exec nginx nginx -s reload
EOF

# Make reload script executable
chmod +x /data/nginx/reload.sh

# Set proper permissions
chown -R $SUDO_USER:$SUDO_USER /data/nginx

# Stop and remove existing container if exists
docker stop nginx >/dev/null 2>&1
docker rm nginx >/dev/null 2>&1

# Run Nginx container
docker run -d \
    --name nginx \
    --restart always \
    -p 80:80 \
    -v /data/nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
    -v /data/nginx/conf.d:/etc/nginx/conf.d:ro \
    -v /data/nginx/logs:/var/log/nginx \
    -v /data/nginx/html:/usr/share/nginx/html \
    nginx:stable

echo "Nginx has been installed and configured:"
echo "- HTTP Port: 80"
echo "- Config directory: /data/nginx/conf.d"
echo "- Logs directory: /data/nginx/logs"
echo "- HTML directory: /data/nginx/html"
echo ""
echo "To modify configuration:"
echo "1. Edit files in /data/nginx/conf.d/"
echo "2. Run 'sudo /data/nginx/reload.sh' to apply changes" 