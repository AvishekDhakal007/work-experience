#!/bin/bash

# If anything breaks, stop the whole script.
# This prevents half-installed servers.
set -e

echo "Starting automated server setup..."

# I run this first so Ubuntu refreshes its list of available packages.
# Without this, Ubuntu might install outdated software.
sudo apt update -y

# This upgrades already installed packages to their latest versions.
# I do this to avoid security issues and dependency problems.
sudo apt upgrade -y

# Install Nginx, which is the web server that shows our website.
sudo apt install nginx -y

# Install MariaDB (similar to MySQL). This handles databases.
sudo apt install mariadb-server -y

# Install PHP so dynamic web pages can run,
# and php-mysql so PHP can communicate with MariaDB.
sudo apt install php-fpm php-mysql -y

# These commands make sure the services automatically start
# whenever the server reboots.
sudo systemctl enable nginx
sudo systemctl enable mariadb
sudo systemctl enable php8.1-fpm

# Start the services immediately instead of waiting for reboot.
sudo systemctl start nginx
sudo systemctl start mariadb

# ---------------- FIREWALL SETUP ----------------

# Allow SSH so I can still connect to the server remotely.
sudo ufw allow OpenSSH

# Allow normal web traffic.
sudo ufw allow 80

# Allow secure HTTPS traffic.
sudo ufw allow 443

# Turn on the firewall.
# I pipe "y" into the command so it doesn't stop and ask for confirmation.
echo "y" | sudo ufw enable

# ---------------- SSH SECURITY ----------------

# Disable logging in as root.
# This is important because attackers often try to brute-force root.
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Disable password login and force SSH keys.
# SSH keys are much safer than passwords.
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH so the security changes take effect.
sudo systemctl restart ssh

# ---------------- WEBSITE SETUP ----------------

# Remove the default Nginx welcome page to show this is a fresh setup.
sudo rm -f /var/www/html/index.nginx-debian.html

# Nginx serves files from /var/www/html by default.
# Here I create my own index.html to prove the automation worked.
sudo tee /var/www/html/index.html > /dev/null <<EOF
<html>
<head>
<title>Provisioned</title>
</head>
<body style="text-align:center; font-family:Arial;">
<h1>Provisioned by Avishek Dhakal</h1>
<p>This server was fully deployed using Infrastructure as Code.</p>
</body>
</html>
EOF

# Give Nginx ownership of the website files.
sudo chown -R www-data:www-data /var/www/html

# Set proper file permissions so the server can read everything.
sudo chmod -R 755 /var/www/html

# Restart Nginx so it loads the new webpage.
sudo systemctl restart nginx

# ---------------- DATABASE HARDENING ----------------

# Remove anonymous database users (default insecure setting).
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"

# Prevent root database login from outside the server.
sudo mysql -e "UPDATE mysql.user SET Host='localhost' WHERE User='root';"

# Delete the default test database.
sudo mysql -e "DROP DATABASE IF EXISTS test;"

# Remove any leftover test permissions.
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"

# Apply all database security changes.
sudo mysql -e "FLUSH PRIVILEGES;"

# Show completion message.
echo "================================="
echo "Setup Complete!"
echo "Firewall Status:"
sudo ufw status
echo "Open your server IP in your browser."
echo "================================="
