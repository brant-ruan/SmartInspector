#!/bin/bash

# this script is used to install and config zabbix-agent on compute node
# sudo needed, params need to be passed to bash as command line arguments
# ! install zabbix-server firstly since it's ip will be used as paramter

# $1 zabbix-server ip 
# $2 PSK sequence number  such as : 001、002、003 (used to distinguish different agent)

sudo rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
sudo yum install zabbix-agent -y

sudo sh -c "openssl rand -hex 32 > /etc/zabbix/zabbix_agentd.psk"
sudo sed -i "s/Server=127.0.0.1/Server=$1/g" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/# TLSConnect=unencrypted/TLSConnect=psk/g" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/# TLSAccept=unencrypted/TLSAccept=psk/g" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/# TLSPSKIdentity=/TLSPSKIdentity=PSK $2/g" /etc/zabbix/zabbix_agentd.conf
sudo sed -i "s/# TLSPSKFile=/TLSPSKFile=\/etc\/zabbix\/zabbix_agentd.psk/g" /etc/zabbix/zabbix_agentd.conf

sudo systemctl start zabbix-agent 
sudo systemctl enable zabbix-agent
sudo iptables -I INPUT -p tcp --dport 10050 -j ACCEPT
