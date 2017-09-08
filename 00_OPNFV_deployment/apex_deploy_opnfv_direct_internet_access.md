# Network Configuration Guide
## Deploy OPNFV
you had better use screen to avoid accidential disconnection caused by Internet

```shell
opnfv-clean
cd /etc/opnfv-apex/
opnfv-deploy -v --virtual-cpus 8 --virtual-default-ram 64 --virtual-compute-ram 96 -n network_settings.yaml -d os-nosdn-nofeature-ha.yaml --debug
```
## Manual network configuration 

Find your compute nodes and controller nodes ip
```shell
opnfv-util-undercloud 
source stackrc
nova list
```
Network configuration is needed in all nodes

```shell
ssh heat-admin@192.0.2.x
```
### on controller nodes
```shell
sudo -i
vim /etc/sysconfig/network-scripts/ifcfg-br-ex
```
change netmask to 255.255.255.0
```shell
vim /etc/sysconfig/network-scripts/route-br-ex
```
change default gateway to 192.168.32.1, you can see something like 'default via 192.168.32.1'
### on compute nodes
Firstly 'route -n' to find out interface associated with 192.168.32.x ip address, then edit ifcfg-xxx and route-xxx file
## Network configuration via Ansible 
Make sure you hosts file was configured properly
```shell
ansible controller -m ping 
```
```shell
ansible compute -m ping
```
You should see all green output, you had better disable ansible SSH key host checking for better experience