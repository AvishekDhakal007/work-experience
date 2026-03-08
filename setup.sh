#!/bin/bash

echo "Updating system packages..."
sudo apt update -y

echo "Installing Nginx..."
sudo apt install nginx -y

echo "Starting Nginx service..."
sudo systemctl start nginx

echo "Enabling Nginx to start on boot..."
sudo systemctl enable nginx

echo "Allowing HTTP traffic through firewall..."
sudo ufw allow 'Nginx Full'

echo "Creating sample website..."

sudo bash -c 'cat <<EOL > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>DevOps Server</title>
</head>
<body>
<h1>Server Deployment Successful</h1>
<p>This website is running on Nginx.</p>
</body>
</html>
EOL'

echo "Restarting Nginx..."
sudo systemctl restart nginx

echo "Setup complete. Nginx server is running."
