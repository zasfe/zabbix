
# troubleshooting

## Zabbix Server

### less than 25% free in the configuration cache 

```
vi /etc/zabbix/zabbix_server.conf
CacheSize=24M
service zabbix-server restart

Default CacheSize size is 8M
```

