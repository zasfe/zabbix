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
mysql -uroot -p$MYSQL_ROOT_PASSWORD << EOF
CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost' IDENTIFIED BY 'zabbix';
EOF
   
mysql -uzabbix -pzabbix zabbix < database/mysql/schema.sql
mysql -uzabbix -pzabbix zabbix < database/mysql/images.sql
mysql -uzabbix -pzabbix zabbix < database/mysql/data.sql

# Edit /usr/local/etc/zabbix_server.conf:
DBHost=localhost
DBName=zabbix
DBUser=zabbix
DBPassword=zabbix

# Edit /etc/systemd/system/zabbix-server.service:
[Unit]
Description=Zabbix Server
After=syslog.target network.target mysqld.service

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/zabbix_server -c /usr/local/etc/zabbix_server.conf
ExecReload=/usr/local/sbin/zabbix_server -R config_cache_reload
RemainAfterExit=yes
PIDFile=/run/zabbix/zabbix_server.pid

[Install]
WantedBy=multi-user.target


# Edit /etc/systemd/system/zabbix-agent.service:
[Unit]
Description=Zabbix Agent
After=syslog.target network.target network-online.target
Wants=network.target network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/zabbix_agentd -c /usr/local/etc/zabbix_agentd.conf
RemainAfterExit=yes
PIDFile=/var/run/zabbix/zabbix_agentd.pid

[Install]
WantedBy=multi-user.target


# Enable & Start Services:
systemctl daemon-reload
systemctl enable zabbix-server
systemctl enable zabbix-agent
systemctl start zabbix-server
systemctl start zabbix-agent


Copy Frontend Files to Web-Server Document Root:
mkdir -p /var/www/html/zabbix
cp -r frontends/php/* /var/www/html/zabbix/



# https://docs.j7k6.org/raspberry-pi-zabbix/










