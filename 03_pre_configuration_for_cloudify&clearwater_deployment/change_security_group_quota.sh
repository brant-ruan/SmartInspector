#!/bin/bash

# this should be executed in all of the controller nodes
# use ansible for your configuration
# ansible controller -m script -a "./change_security_group_quota.sh" --sudo

neutronConf="/etc/neutron/neutron.conf"
sed -i "s|^#quota_security_group.*$|quota_security_group = 50|" \
$neutronConf
sed -i "s|^#quota_security_group_rule.*$|quota_security_group_rule = 500|" \
$neutronConf
systemctl restart neutron-server

