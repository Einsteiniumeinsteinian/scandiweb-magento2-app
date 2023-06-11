#!/bin/bash
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer

cd /var/www/html/
read -s -p "PRIVATE KEY Password: " PRIVATE_KEY
read -s -p "Enter PUBLIC KEY password: " PUBLIC_KEY
composer config --global http-basic.repo.magento.com $PUBLIC_KEY $PRIVATE_KEY
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.3 magento2

read -s -p " Input MAGENTO2 DB Password: " DB_PASSWORD
echo -e "\n"
read -s -p "Input Base URL Address: " B_ADDRESS
echo -e "\n"
read -s -p "Input Admin Username: " Admin_Username
echo -e "\n"
read -s -p "Input Admin Password: " Admin_Password
echo -e "\n"
read -s -p "Input Admin Email: " Admin_Email

cd /var/www/html/magento2/bin
./magento setup:install --base-url=https://$B_ADDRESS/ \
--db-host=localhost --db-name=magento --db-user=magento2 --db-password=$DB_PASSWORD \
--admin-firstname=Admin --admin-lastname=User --admin-email=$Admin_Email \
--admin-user=$Admin_Username --admin-password=$Admin_Password --language=en_US \
--currency=USD --timezone=America/New_York --use-rewrites=1 \
--elasticsearch-host=localhost --elasticsearch-port=9200

echo -e "\n"
echo "setting permissions"
cd /var/www/html/magento2
find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} \;
find var vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} \;
chown -R :www-data.
chmod u+x bin/magento



# Add cron jobs to crontab
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/html/magento2/bin/magento cron:run >> /var/www/html/magento2/var/log/cron.log") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/html/magento2/update/cron.php >> /var/www/html/magento2/var/log/update.log") | crontab -
(crontab -l 2>/dev/null; echo "* * * * * /usr/bin/php /var/www/html/magento2/bin/magento setup:cron:run >> /var/www/html/magento2/var/log/setup.log") | crontab -
echo "Cron jobs added successfully."
