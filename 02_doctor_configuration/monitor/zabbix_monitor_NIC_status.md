# Zabbix monitor NIC status

## Node/VM to be monitored
```shell
cd /etc/zabbix/zabbix_agentd.d/
# create UserParamter, create a new one if not exist
vim userparameter_niclink.conf
```
add the following UserParameter
```shell
UserParameter=net.if.link[*], if [ $(cat /sys/class/net/$1/operstate) = "up" ]; then cat /sys/class/net/$1/carrier; else echo "0"; fi;
```
Restart agent
```shell
systemctl restart zabbix-agent
```
## Zabbix server UI
Create an Item against the host as follows:
- Type: Zabbix agent (active if appropriate).
- Key: has the actual NIC to be monitored between brackets, eg: net.if.link[eth2],
- Type of information: Numeric (unsigned); Data type: Decimal
- Show Value: as "Service state" (displays them as "Up/Down")
- Application: Network Interfaces


