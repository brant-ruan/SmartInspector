# Zabbix Configuration Guide

After install Zabbix server and Zabbix agent, the following settings should be applied in Zabbix web UI. (If you install zabbix server in one of your controller node which is on the same network with your laptop, ip addres of your zabbix server could be one of your controller node's ip address or your openstack dashboard ip address, simply add postfix "/zabbix",eg: http://openstack_dashbord_ip/zabbix)

## Configuring settings for zabbix web interface

Zabbix web interface needs some initial setup before we can use it, launch your browser and go to the address http://your_zabbix_server_ip/zabbix/. Filling the needed information and click Next stop to proceed

## Adding new host to be monitored to the zabbix server

- Log in to the zabbix server interface
- Configuration-> Hosts-> Create host, 
hostname and ip address of your client machine is necessary for zabbix server to contact to your machine, the information needed in Encryption settings tab can be found in /etc/zabbix/zabbix-agentd.conf
- After several seconds you can navigate to Monitoring and then Latest data to see the data from your agent
