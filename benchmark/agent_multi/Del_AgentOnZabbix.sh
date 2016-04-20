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

cat /etc/zabbix_agent_multi/agent_multi_list_hostids | while IFS= read hostids ; do
  curl -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"host.delete\",\"params\":[\""${hostids}"\"],\"auth\":\""${AUTH_TOKEN}"\",\"id\":0}" $API
done

