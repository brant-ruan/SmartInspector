#!/bin/bash

# you had better use screen to avoid accidential disconnection caused by Internet
opnfv-clean
cd /etc/opnfv-apex/
opnfv-deploy -v --virtual-cpus 8 --virtual-default-ram 64 --virtual-compute-ram 96 -n network_settings.yaml -d os-nosdn-nofeature-ha.yaml --debug
# network configuration

opnfv-util-undercloud 
source stackrc
nova list
# should be done in all nodes
## on controller nodes
ssh heat-admin@192.0.2.6
sudo -i
vim /etc/sysconfig/network-scripts/ifcfg-br-ex
# change netmask to 255.255.255.0
vim /etc/sysconfig/network-scripts/route-br-ex
# change default gateway to 192.168.32.1
default via 192.168.32.1
## on compute nodes
### first route -n to find out interface associated with 192.168.32.x ip address 
### edit ifcfg-xxx and route-xxx