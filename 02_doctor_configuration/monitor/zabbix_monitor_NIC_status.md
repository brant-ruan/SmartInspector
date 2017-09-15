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
Test if your setting works properly locally
```shell
# find the location of zabbix-agent binary file 
rpm -ql zabbix-agent
# it's /usr/sbin/zabbix_agentd in our configuration
# test locally
/usr/sbin/zabbix_agentd -t net.if.link[eth2]
```
If the thing works properly locally, next step is configuration on remote zabbix server machine
## Zabbix server web interface 
Create an monitor item against the host as follows:
- Type: Zabbix agent (active if appropriate).
- Key: has the actual NIC to be monitored between brackets, eg: net.if.link[eth2],
- Type of information: Numeric (unsigned); Data type: Decimal
- Show Value: as "Service state" (displays them as "Up/Down")
- Application: Network Interfaces

Make the item we added is enabled, you can navigate to Monitoring and then Latest data to see the data that supposed to be monitored
