#!/bin/bash

# Update the system
sudo apt update
sudo apt upgrade -y

# Install Apache
sudo apt install apache2 -y

# Install MySQL and set root password
sudo apt install mariadeb-server -y
sudo mysql_secure_installation


	# MySQL root credentials
	mysql_user="root"
	mysql_password="hacker"

	# Database and user details
	database_name="wordpress"
	new_user="root"
	new_user_password="hacker"

	# MySQL commands
	mysql_cmd="mysql -u $mysql_user -p$mysql_password"

	# Create the database
	$mysql_cmd -e "CREATE DATABASE IF NOT EXISTS $database_name;"

	# Create the user and grant privileges
	$mysql_cmd -e "CREATE USER '$new_user'@'localhost' IDENTIFIED BY '$new_user_password';"
	$mysql_cmd -e "GRANT ALL PRIVILEGES ON $database_name.* TO '$new_user'@'localhost' IDENTIFIED BY '$new_user_password';"
	$mysql_cmd -e "FLUSH PRIVILEGES;"

	echo "MySQL database and user created successfully!"



# Install PHP and required extensions
sudo apt install php libapache2-mod-php php-mysql -y

# Enable Apache modules
sudo a2enmod rewrite
sudo systemctl restart apache2

# Download and extract WordPress
cd /var/www/html
sudo rm index.html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo mv wordpress/* .
sudo rm -r wordpress
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

# Configure WordPress database
sudo mysql -u root -p << MYSQL_SCRIPT
CREATE DATABASE wordpress;
CREATE USER 'root'@'localhost' IDENTIFIED BY 'hacker';
GRANT ALL PRIVILEGES ON wordpress.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
EXIT
MYSQL_SCRIPT

# Configure WordPress configuration file
sudo mv wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/wordpress/" wp-config.php
sudo sed -i "s/username_here/root/" wp-config.php
sudo sed -i "s/password_here/hacker/" wp-config.php

# Restart Apache
sudo systemctl restart apache2

# Clean up
sudo rm latest.tar.gz

echo "WordPress installation is complete."

echo
echo "Include Theme Auto Customization Command Support"
