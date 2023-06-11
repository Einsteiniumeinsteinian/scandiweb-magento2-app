#! /bin/bash
apt update
apt install software-properties-common
add-apt-repository ppa:ondrej/php
apt update

apt-get install -y php7.4 php7.4-fpm php7.4-curl php7.4-xml php7.4-xmlwriter \
 php7.4-gd php7.4-intl php7.4-mysql php7.4-zip \
 php7.4-soap zip php7.4-mbstring php7.4-bcmath

#config here
systemctl start php7.4-fpm
systemctl enable php7.4-fpm
service php7.4-fpm status