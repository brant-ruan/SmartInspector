# Network Configuration Guide
## Deploy OPNFV
you had better use screen to avoid accidential disconnection caused by Internet
```shell
opnfv-clean
cd /etc/opnfv-apex/
opnfv-deploy -v --virtual-cpus 8 --virtual-default-ram 64 --virtual-compute-ram 96 -n network_settings.yaml -d os-nosdn-nofeature-ha.yaml --debug
```

## Network configuration via Ansible 
Make sure you hosts file was configured properly and you had better disable ssh hosts key checking to avoid further annnoying

Disable ssh host key checking:
```shell
sudo vim /etc/ansible/ansible.cfg
```
then uncomment host_key_checking = False

Check if your ansible hosts file was configured properly
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
## Last step
You may need to delete the subnet of default external network and creat a new one because it's network mask generated during Apex installing process is /25,netmask should be /24 during our installation process. You can do it manauly via OpenStack dashboard or by OpenStack commands
```shell
# delete external default subnet
neutron subnet-delete external-net 
# recreate external subnet
neutron subnet-create external 192.168.32.0/24  --name  external-net --dns-nameserver 8.8.8.8 --gateway 192.168.32.1 --allocation-pool start=192.168.32.191,end=192.168.32.250  
```

