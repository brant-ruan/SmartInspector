#!/bin/bash
neutronConf="/etc/neutron/neutron.conf"
sed -i "s|^#quota_security_group.*$|quota_security_group = 50|" \
$neutronConf
sed -i "s|^#quota_security_group_rule.*$|quota_security_group_rule = 500|" \
$neutronConf

