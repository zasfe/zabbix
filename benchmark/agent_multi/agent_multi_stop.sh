#!/bin/bash

if [ -f /etc/zabbix_agent_multi/agent_multi_list_pids ]
then
  cat /etc/zabbix_agent_multi/agent_multi_list_pids | while IFS= read pidfile ; do
    if [ -f "${pidfile}" ]
    then
      pid=`cat ${pidfile}`
      kill -TERM $pid >/dev/null 2>&1
      usleep 100000
      if [ `ps -ef | awk '{print$2}' | grep ${pid} | wc -l` -ne 0 ]
      then
        kill -KILL $pid >/dev/null 2>&1
        usleep 100000
      fi
    fi
  done
fi
