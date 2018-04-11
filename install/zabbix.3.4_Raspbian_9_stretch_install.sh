#!/bin/bash

mkdir src
cd src

# 1. Update the system
sudo apt-get -y update

exit

# 2. Install the following packages
sudo apt-get -y install sqlite3 libsqlite3-dev
sudo apt-get install fping sqlite3 libsnmp-dev php5-gd php5-sqlite php5-dev libiksemel-dev libsqlite3-dev libcurl4-openssl-dev php5-curl make



# Create user account
sudo groupadd zabbix
sudo useradd -g zabbix zabbix

# Download the source archive
wet -O zabbix-3.4.8.tar.gz https://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/3.4.8/zabbix-3.4.8.tar.gz/download
cd zabbix-3.4.8
./configure --enable-server --enable-agent --with-sqlite3 --with-net-snmp --with-jabber --with-libcurl
make
make install

# Zabbix DB(sqlite) Setting
mkdir /var/lib/sqlite
cd database/sqlite
sqlite/var/lib/sqlite/zabbix.db < schema.sql
sqlite/var/lib/sqlite/zabbix.db < images.sql
sqlite/var/lib/sqlite/zabbix.db < data.sql
chown-R zabbix:zabbix /var/lib/sqlite
chmod 774 /var/lib/sqlite 
chmod 664 /var/lib/sqlite/zabbix.db
