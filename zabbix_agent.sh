#!/bin/bash

# on each compute node
# to install zabbix-agent

# install
sudo rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
sudo yum install zabbix-agent

# PSK encryption

# remain to complete

