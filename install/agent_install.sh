#!/bin/bash
groupadd zabbix
useradd -g zabbix zabbix -s /sbin/nologin
cd /usr/local
wget http://sourceforge.net/projects/zabbix/files/ZABBIX%20Latest%20Stable/2.2.5/zabbix-2.2.5.tar.gz
/bin/tar xf zabbix-2.2.5.tar.gz
cd zabbix-2.2.5
./configure --prefix=/usr/local/zabbix_agentd --enable-agent
make && make install
mkdir /usr/local/zabbix_agentd/log
chown -R zabbix.zabbix /usr/local/zabbix_agentd
cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
chmod 755 /etc/init.d/zabbix_agentd
ln -s /usr/local/zabbix_agentd/bin/* /usr/bin/
ln -s /usr/local/zabbix_agentd/sbin/* /usr/sbin/
sed -i "s#BASEDIR=/usr/local#BASEDIR=/usr/local/zabbix_agentd#g" /etc/init.d/zabbix_agentd                       //注意指定zabbix_agentd 的目录
serverip=10.6.24.207
sed -i "s#Server=127.0.0.1#Server=$serverip#g" /usr/local/zabbix_agentd/etc/zabbix_agentd.conf
sed -i "s#LogFile=/tmp/zabbix_agentd.log#LogFile=/usr/local/zabbix_agentd/log/zabbix_agentd.log#g" /usr/local/zabbix_agentd/etc/zabbix_agentd.conf
sed -i "s@ServerActive=127.0.0.1@#ServerActive=127.0.0.1@g" /usr/local/zabbix_agentd/etc/zabbix_agentd.conf
localip=`ifconfig | grep inet | head -1 | cut -d: -f2 | cut -d " " -f1`
sed -i "s#Hostname=Zabbix server#Hostname=$localip#" /usr/local/zabbix_agentd/etc/zabbix_agentd.conf
chkconfig zabbix_agentd on
service zabbix_agentd start
if [ $? == 0 ];then
    echo "The zabbix_agent is installed"
else
    echo "Somethine is wrong with the zabbix_agentd"
fi
