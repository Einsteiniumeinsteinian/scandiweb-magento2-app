#!/bin/bash
 apt update
 apt install -y mysql-server
 systemctl enable mysql.service
 systemctl restart mysql.service
 service mysql status

read -s -p "Enter MySQL password: " MYSQL_PASSWORD
read -s -p "Enter MySQL MAGENTO password: " MYSQL_MAGENTO_PASSWORD

echo
# Check if the database already exists
DB_EXISTS=$( mysql -u root -p"$MYSQL_PASSWORD" -e "SHOW DATABASES LIKE 'magento'" | grep magento)

if [[ -n "$DB_EXISTS" ]]; then
  echo "Database 'magento' already exists."
else
  # SQL commands to execute
SQL_COMMANDS="CREATE DATABASE magento;
CREATE USER 'magento2'@'localhost' IDENTIFIED BY '${MYSQL_MAGENTO_PASSWORD}';
GRANT ALL PRIVILEGES ON magento.* TO 'magento2'@'localhost';
FLUSH PRIVILEGES;"

  # Execute the SQL commands using mysql
echo "$SQL_COMMANDS" |  mysql -u root -p"$MYSQL_PASSWORD"

  # Check the exit code
  if [ $? -eq 0 ]; then
    echo "SQL commands executed successfully."
    DB_EXISTS=$( mysql -u root -p"$MYSQL_PASSWORD" -e "SHOW DATABASES LIKE 'magento'" | grep magento)
    echo $DB_EXISTS
  else
    echo "Error executing SQL commands."
  fi
fi


