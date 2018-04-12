#!/bin/bash

mkdir src
cd src

# 1. Update the system
sudo apt-get -y update

exit

# 2. Install the following packages
export DEBIAN_FRONTEND=noninteractive
export MYSQL_ROOT_PASSWORD="$PASSWORD"

echo mysql-server mysql-server/root_password select $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections
echo mysql-server mysql-server/root_password_again select $MYSQL_ROOT_PASSWORD | sudo debconf-set-selections

sudo apt-get update
sudo apt-get install -y \
  build-essential \
  curl \
  mariadb-server \
  libxml2-dev \
  libcurl4-openssl-dev \
  libmariadbclient-dev \
  libsnmp-dev \
  libevent-dev \
  libpcre3-dev \
  snmp-mibs-downloader \
  snmp \
  nginx \
  php7.0-fpm \
  php7.0-mysql \
  php7.0-gd \
  php7.0-mbstring \
  php7.0-bcmath \
  php7.0-xml

# Create user account
sudo groupadd zabbix
sudo useradd -g zabbix zabbix

# Build & Install Zabbix:
wet -O zabbix-3.4.8.tar.gz https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.4.8/zabbix-3.4.8.tar.gz/download
tar zxvf zabbix-3.4.8.tar.gz
cd zabbix-3.4.8
./configure \
  --enable-server \
  --enable-agent \
  --with-mysql \
  --with-net-snmp \
  --with-libcurl \
  --with-libxml2
make install

# 4.Setup Database:
mysql -uroot << EOF
CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';
EOF
   
mysql -uzabbix -pzabbix zabbix < database/mysql/schema.sql
mysql -uzabbix -pzabbix zabbix < database/mysql/images.sql
mysql -uzabbix -pzabbix zabbix < database/mysql/data.sql

# Edit /usr/local/etc/zabbix_server.conf:
cp -pa conf/zabbix_server.conf /usr/local/etc/zabbix_server.conf
sed -i 's/# DBHost=localhost/DBHost=localhost/g' /usr/local/etc/zabbix_server.conf
sed -i 's/# DBPassword=/# DBPassword=\nDBPassword=zabbix/g' /usr/local/etc/zabbix_server.conf

# Edit /usr/local/etc/zabbix_server.conf:
cp -pa zabbix_agentd.conf /usr/local/etc/zabbix_agentd.conf


# Enable & Start Services:
cp -pa misc/init.d/debian/zabbix-* /etc/init.d/

/etc/init.d/zabbix-server start
/etc/init.d/zabbix-agent start

# Copy Frontend Files to Web-Server Document Root:
mkdir -p /var/www/html/zabbix
cp -r frontends/php/* /var/www/html/zabbix/


# referal
# https://docs.j7k6.org/raspberry-pi-zabbix/










