#!/bin/sh

yum groupinstall "Development Libraries"
yum groupinstall "Development Tools"
yum groupinstall "Legacy Software Development"


## Step 1: Set Up Apache, MySQL and PHP

# Install All Services
yum -y install httpd httpd-devel 
yum -y install mysql mysql-server 
yum -y install php php-cli php-common php-devel php-pear php-gd php-mbstring php-mysql php-xml php-bcmath gd
yum -y install OpenIPMI libssh2 fping libcurl net-snmp gcc automake curl-devel net-snmp-devel OpenIPMI-devel

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

# CentOS/RHEL 7:
rpm -Uvh http://repo.zabbix.com/zabbix/2.2/rhel/7/x86_64/zabbix-release-2.2-1.el7.noarch.rpm

# CentOS/RHEL 6:
rpm -Uvh http://repo.zabbix.com/zabbix/2.2/rhel/6/x86_64/zabbix-release-2.2-1.el6.noarch.rpm

CentOS/RHEL 5:
# rpm -Uvh http://repo.zabbix.com/zabbix/2.2/rhel/5/x86_64/zabbix-release-2.2-1.el5.noarch.rpm


## Step 3: Install Zabbix Server with MySQL
yum install zabbix-server-mysql zabbix-web-mysql zabbix-agent zabbix-java-gateway


## Step 4: Setup Zabbix Apache Configuration

# vi /etc/httpd/conf.d/zabbix.conf
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
# vi /etc/php.ini
max_execution_time = 300
date.timezone =Asia/Seoul
memory_limit = 1024M
post_max_size = 32M
max_input_time = 300

service httpd restart


## Step 4: Create Zabbix MySQL Database

 mysql -u root -p

mysql> CREATE DATABASE zabbix CHARACTER SET UTF8;
mysql> GRANT ALL PRIVILEGES on zabbix.* to 'zabbix'@'localhost' IDENTIFIED BY 'SECRET_PASSWORD';
mysql> FLUSH PRIVILEGES;
mysql> quit
