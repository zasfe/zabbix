#!/bin/bash

mkdir -p /etc/zabbix_agent_multi

if [ -f /etc/zabbix_agent_multi/agent_multi_list_pids ]
then
 rm -f /etc/zabbix_agent_multi/agent_multi_list_pids
fi

for agent_num in {1..250}
do
  echo "Welcome ${agent_num} times"
  agent_port="$((30000 + ${agent_num}))"
  HOSTNAME="zabbix_agent_${agent_num}"
  conf_file="/etc/zabbix_agent_multi/zabbix_agentd${agent_num}.conf"

  echo "PidFile=/var/run/zabbix/zabbix_agentd${agent_num}.pid" > ${conf_file}
  echo "LogFile=/var/log/zabbix/zabbix_agentd${agent_num}.log" >> ${conf_file}
	echo "HOSTNAME=zabbix_agent_${agent_num}" >> ${conf_file}
  echo "LogFileSize=10" >> ${conf_file}
  echo "DebugLevel=0" >> ${conf_file}
  echo "Server=192.169.253.7" >> ${conf_file}
  echo "ListenPort=${agent_port}" >> ${conf_file}
  echo "ListenIP=0.0.0.0" >> ${conf_file}

  # /etc/zabbix_agent_multi/agent_multi_run.sh
  echo "/usr/sbin/zabbix_agentd -c /etc/zabbix_agent_multi/zabbix_agentd${agent_num}.conf" >> agent_multi_run.sh
  echo "/var/run/zabbix/zabbix_agentd${agent_num}.pid" >> /etc/zabbix_agent_multi/agent_multi_list_pids
done

chmod +x agent_multi_run.sh
