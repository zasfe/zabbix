#!/bin/sh

## Step 0: Packeges Update
yum -y update

## Step 1: Set Up Apache, MariaDB(instead of MySQL) and PHP

# Install All Services
yum -y install httpd httpd-devel

cat > /etc/yum.repos.d/MariaDB.repo << EOF
# MariaDB 10.2 CentOS repository list - created 2018-10-08 04:44 UTC
# http://downloads.mariadb.org/mariadb/repositories/
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.2/centos6-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

yum -y install MariaDB-server
