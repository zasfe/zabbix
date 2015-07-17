#!/bin/sh

## Step 1: Set Up Apache, MySQL and PHP

# Install All Services
yum -y install httpd httpd-devel 
yum -y install mysql mysql-server mysql-devel 
yum -y install php php-cli php-common php-devel php-pear php-gd php-mbstring php-mysql php-xml php-bcmath gd

yum -y install gcc automake

yum -y install OpenIPMI OpenIPMI-devel
yum -y install libcurl curl-devel
yum -y install net-snmp net-snmp-devel
yum -y install libssh2 libssh2-devel 
yum -y install fping 
yum -y install libxml2-devel
yum -y install unixODBC unixODBC-devel
yum -y install java-1.7.0-openjdk*


wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/aevseev/CentOS_CentOS-6/x86_64/iksemel-1.4-20.1.x86_64.rpm
wget ftp://ftp.pbone.net/mirror/ftp5.gwdg.de/pub/opensuse/repositories/home:/aevseev/CentOS_CentOS-6/x86_64/iksemel-devel-1.4-20.1.x86_64.rpm
rpm -ivh iksemel-1.4-20.1.x86_64.rpm
rpm -ivh iksemel-devel-1.4-20.1.x86_64.rpm

# Start All Services
service httpd start
service mysqld start

# MySQL Initial Setup
mysql_secure_installation


## Step 2: Configure Yum Repository ( 2.2 LTS )

cd /usr/local/src
wget -O zabbix-2.2.9.tar.gz http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/2.2.9/zabbix-2.2.9.tar.gz/download
tar zxvf zabbix-2.2.9.tar.gz
cd zabbix-2.2.9

/bin/cp -pa ./frontends/php /var/www/html/zabbix
touch /var/www/html/zabbix/conf/zabbix.conf.php
chmod 755 /var/www/html/zabbix/conf/zabbix.conf.php
chown apache.apache /var/www/html/zabbix/conf/zabbix.conf.php

./configure --prefix=/usr/local/zabbix-2.2.9 --enable-server --enable-agent --enable-java --with-mysql --with-net-snmp --with-libcurl --with-libxml2 --with-unixodbc --with-openipmi --with-ssh2 --with-iconv
make install
ln -s /usr/local/zabbix-2.2.9 /usr/local/zabbix

cat ./misc/init.d/fedora/core/zabbix_server | sed -e "s/sbin/zabbix\/sbin/" > /etc/rc.d/init.d/zabbix_server
chmod 775 /etc/rc.d/init.d/zabbix_server


mysql -uroot -e "create database zabbix character set utf8"
mysql -uroot -e "grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix'"
mysql -uroot zabbix < ./database/mysql/schema.sql
mysql -uroot zabbix < ./database/mysql/images.sql
mysql -uroot zabbix < ./database/mysql/data.sql


/bin/cp -pa /usr/local/zabbix/etc/zabbix_server.conf /usr/local/zabbix/etc/zabbix_server.conf.ori
cat /usr/local/zabbix/etc/zabbix_server.conf | sed -e "s/# StartPollers=5/StartPollers=5/" -e "s/# StartPingers=1/StartPingers=5/" -e "s/# StartDiscoverers=1/StartDiscoverers=1/" -e "s/# StartHTTPPollers=1/StartHTTPPollers=5/" -e "s/# ListenIP=0.0.0.0/ListenIP=0.0.0.0/" -e "s/# JavaGateway=/JavaGateway=127.0.0.1/" -e "s/# JavaGatewayPort=10052/JavaGatewayPort=10052/" -e "s/# StartJavaPollers=0/StartJavaPollers=5/" -e "s/# AllowRoot=0/AllowRoot=1/" > /usr/local/zabbix/etc/zabbix_server.conf.tmp
/bin/cp -pa /usr/local/zabbix/etc/zabbix_server.conf.tmp /usr/local/zabbix/etc/zabbix_server.conf

exit




# CentOS/RHEL 7:
rpm -Uvh http://repo.zabbix.com/zabbix/2.2/rhel/7/x86_64/zabbix-release-2.2-1.el7.noarch.rpm

# CentOS/RHEL 6:
rpm -Uvh http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm

# CentOS/RHEL 5:
rpm -Uvh http://repo.zabbix.com/zabbix/2.2/rhel/5/x86_64/zabbix-release-2.2-1.el5.noarch.rpm


## Step 3: Install Zabbix Server with MySQL
yum -y install zabbix-server-mysql zabbix-web-mysql zabbix-agent zabbix-java-gateway


## Step 4: Setup Zabbix Apache Configuration


cat >> /etc/httpd/conf.d/zabbix.conf << EOF

php_value date.timezone Asia/Seoul

    Alias /zabbix /var/www/html/zabbix
    <Directory /var/www/html/zabbix/>
      AllowOverride FileInfo AuthConfig Limit Indexes
      Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
      <Limit GET POST OPTIONS PROPFIND>
        Order allow,deny
        Allow from all
      </Limit>
      <LimitExcept GET POST OPTIONS PROPFIND>
        Order deny,allow
        Deny from all
      </LimitExcept>
    </Directory>

EOF

## vi /etc/php.ini
# max_execution_time = 300
# date.timezone =Asia/Seoul
# memory_limit = 1024M
# post_max_size = 32M
# max_input_time = 300

T_PHP_INI=$(php -i | grep "Loaded Configuration File" | awk '{print$5}')
sed -i 's/^max_execution_time/max_execution_time = 300\n;; defailt setting\n; max_execution_time/' ${T_PHP_INI}
sed -i 's/^date.timezone/;date.timezone/' ${T_PHP_INI}
sed -i 's/;date.timezone/date.timezone =Asia\/Seoul\n;date.timezone/' ${T_PHP_INI}
sed -i 's/^memory_limit/;memory_limit/' ${T_PHP_INI}
sed -i 's/;memory_limit/memory_limit = 1024M\n;memory_limit/' ${T_PHP_INI}
sed -i 's/^post_max_size/;post_max_size/' ${T_PHP_INI}
sed -i 's/;post_max_size/post_max_size = 32M\n;post_max_size/' ${T_PHP_INI}
sed -i 's/^max_input_time/;max_input_time/' ${T_PHP_INI}
sed -i 's/;max_input_time/max_input_time = 300\n;max_input_time/' ${T_PHP_INI}



service httpd restart


## Step 4: Create Zabbix MySQL Database

 mysql -u root -p

mysql> CREATE DATABASE zabbix CHARACTER SET UTF8;
mysql> GRANT ALL PRIVILEGES on zabbix.* to 'zabbix'@'localhost' IDENTIFIED BY 'SECRET_PASSWORD';
mysql> FLUSH PRIVILEGES;
mysql> quit
