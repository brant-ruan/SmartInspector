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
### On controller nodes
```shell
sudo -i
vim /etc/sysconfig/network-scripts/ifcfg-br-ex
```
change netmask to 255.255.255.0
```shell
vim /etc/sysconfig/network-scripts/route-br-ex
```
change default gateway to 192.168.32.1, you can see something like 'default via 192.168.32.1'
### On compute nodes
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

Firstly make sure your controller and compute nodes ip configuration is correct
### On controller nodes
```shell
ansible-playbook opnfv_direct_internet_access_network_configuration_controller.yml
```
### On compute nodes
Make sure the ip which is on the same network with your Jumphost network dev is eth2 before execute this command
```shell
ansible_playbook opnfv_direct_internet_access_network_configuration_compute.yml
```
If everything works fine, you should see all green output

## Last step
You may need to delete the subnet of default external network and creat a new one because it's network mask was generated during Apex installing process (default to 25) and is not the one we want it to be, netmask should be /24 in our installation process.