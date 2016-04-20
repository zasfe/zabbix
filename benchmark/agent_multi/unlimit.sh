#!/bin/bash

sed -i 's/^fs.file-max/#fs.file-max/g' /etc/sysctl.conf
echo "fs.file-max = 65536" >>  /etc/sysctl.conf


sed -i 's/^*/#*/g' /etc/security/limits.conf
echo "" >> /etc/security/limits.conf
echo "*          soft     nproc          65535" >> /etc/security/limits.conf
echo "*          hard     nproc          65535" >> /etc/security/limits.conf
echo "*          soft     nofile         65535" >> /etc/security/limits.conf
echo "*          hard     nofile         65535" >> /etc/security/limits.conf


sed -i 's/^\*/#\*/g' /etc/security/limits.d/90-nproc.conf
sed -i 's/^root/#root/g' /etc/security/limits.d/90-nproc.conf
echo "" >> /etc/security/limits.d/90-nproc.conf
echo "*          soft     nproc          65535" >> /etc/security/limits.d/90-nproc.conf
echo "*          hard     nproc          65535" >> /etc/security/limits.d/90-nproc.conf
echo "*          soft     nofile         65535" >> /etc/security/limits.d/90-nproc.conf
echo "*          hard     nofile         65535" >> /etc/security/limits.d/90-nproc.conf
echo "" >> /etc/security/limits.d/90-nproc.conf
echo "root       soft    nproc     unlimited" >> /etc/security/limits.d/90-nproc.conf

