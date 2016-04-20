#!/bin/bash

# VARIABLES
SERVER='192.169.253.12'
IP=`hostname -I|sed -e 's/ //g'`
API='http://192.169.253.12/zabbix/api_jsonrpc.php'

# CONSTANT VARIABLES
ERROR='0'
ZABBIX_USER='Admin'
ZABBIX_PASS='zabbix'

# Authenticate with Zabbix API
authenticate()
{
  echo `curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\": \"user.login\",\"params\": {\"user\": \"$ZABBIX_USER\",\"password\": \"$ZABBIX_PASS\"},\"id\": 0}" $API | cut -d'"' -f8`
}
AUTH_TOKEN=$(authenticate)



HOST="Linux servers"
TEMP="Template OS Linux"

# Get Host_Group and Template ID's for host creation
get_host_group_id() {
  echo `curl -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"hostgroup.get\",\"params\":{\"output\": \"extend\",\"filter\":{\"name\":[\"$HOST\"]}},\"auth\":\"$AUTH_TOKEN\",\"id\":0}" $API | sed -e 's/[{}]/''/g'  | sed -e 's/[""]/''/g' | grep -Eo groupid:[0-9]* | cut -d":" -f2`
}

get_template_id() {
  echo `curl -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"template.get\",\"params\":{\"output\": \"extend\",\"filter\":{\"host\":[\"$TEMP\"]}},\"auth\":\"$AUTH_TOKEN\",\"id\":0}" $API | sed -e 's/[{}]/''/g' | awk -v RS=',"' -F: '/^templateid/ {print $2}' | sed 's/\(^"\|"$\)//g' | sed -e 's/["]]/''/g'`
}

HOSTGROUPID=$(get_host_group_id)
TEMPLATEID=$(get_template_id)

echo "HOSTGROUPID=${HOSTGROUPID}"
echo "TEMPLATEID=${TEMPLATEID}"
for agent_num in {1..250}
do
  echo "Welcome ${agent_num} times"
  agent_port="$((30000 + ${agent_num}))"
  HOSTNAME="zabbix_agent_${agent_num}"
  
  # Create Host
  output=`curl -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"host.create\",\"params\":{\"host\":\"$HOSTNAME\",\"interfaces\": [{\"type\": 1,\"main\": 1,\"useip\": 1,\"ip\": \"$IP\",\"dns\": \"\",\"port\": \"${agent_port}\"}],\"groups\": [{\"groupid\": \"$HOSTGROUPID\"}],\"templates\": [{\"templateid\": \"$TEMPLATEID\"}],\"inventory_mode\": 0},\"auth\":\"$AUTH_TOKEN\",\"id\":0}" $API | sed -e 's/[{}]/''/g' ` 
  
  hostids=`echo $output | awk -v RS=',"' -F\" '/^result/ {print$5}'`
  echo "${hostids}" >> /etc/zabbix_agent_multi/agent_multi_list_hostids
  echo " - create zabbix host : ${HOSTNAME} / ${hostids} "
done
  
