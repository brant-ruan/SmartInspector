#!/bin/bash

neutronConf="/etc/neutron/neutron.conf"
key1="#quota_security_group"
key2="#quota_security_group_rule"

sed -i "s|^#quota_security_group.*$|quota_security_group = 50|" \
$neutronConf

sed -n "s|^#quota_security_group_rule.*$|quota_security_group_rule = 500|" \
$neutronConf