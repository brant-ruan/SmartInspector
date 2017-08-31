#!/bin/bash

#author:zangyuan
#this script is used to install and config zabbix-agent on compute node
# $1 zabbix-server ip 
# $2 PSK sequence number  such as : 001、002、003

rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm

yum install zabbix-agent

sh -c "openssl rand -hex 32 > /etc/zabbix/zabbix_agentd.psk"

psk=$(cat /etc/zabbix/zabbix_agentd.psk)

sed -i "s/Server=127.0.0.1/Server=$1/g" /etc/zabbix/zabbix_agentd.conf

sed -i "s/# TLSConnect=unencrypted/TLSConnect=psk/g" /etc/zabbix/zabbix_agentd.conf

sed -i "s/# TLSAccept=unencrypted/TLSAccept=psk/g" /etc/zabbix/zabbix_agentd.conf

sed -i "s/# TLSPSKIdentity=/TLSPSKIdentity=PSK $2/g" /etc/zabbix/zabbix_agentd.conf

sed -i "s/# TLSPSKFile=/TLSPSKFile=\/etc\/zabbix\/zabbix_agentd.psk/g" /etc/zabbix/zabbix_agentd.conf

systemctl start zabbix-agent 

systemctl enable zabbix-agent

iptables -I INPUT -p tcp --dport 10050 -j ACCEPT




