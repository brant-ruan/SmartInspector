#!/bin/bash

# sudo needed
# this script is used for installing and config zabbix-server on openstack controller node.

# firstly make sure mysql is started
sudo systemctl start mariadb 
sudo systemctl enable mariadb
sudo rpm -ivh http://repo.zabbix.com/zabbix/3.0/rhel/7/x86_64/zabbix-release-3.0-1.el7.noarch.rpm
sudo yum install zabbix-server-mysql zabbix-web-mysql -y
# you could choose to monitor zabbix server node itself
# yum install zabbix-agent

mysql -u root -e "create database zabbix character set utf8;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
flush privileges;
quit;"

sudo cd /usr/share/doc/zabbix-server-mysql-3.0.10/
zcat create.sql.gz | mysql -uzabbix -p zabbix
sudo sed -i "s/# DBPassword=/DBPassword=zabbix/g" /etc/zabbix/zabbix_server.conf
sudo sed -i "s/# php_value date.timezone Europe\/Riga/php_value date.timezone Asia\/Shanghai/g" /etc/httpd/conf.d/zabbix.conf

sudo systemctl restart httpd 
sudo systemctl start zabbix-server 
sudo systemctl enable zabbix-server 
sudo iptables -I INPUT -p tcp --dport 10051 -j ACCEPT