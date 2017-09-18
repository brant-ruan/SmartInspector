# Ansible

ansible default configuration file path /etc/ansible

An example hosts file looks like:

```
[controller]
192.0.2.6  ansible_ssh_user=heat-admin
192.0.2.10 ansible_ssh_user=heat-admin
192.0.2.3  ansible_ssh_user=heat-admin
```
Disable ssh key host checking to avoid annoying
```shell
sudo vim /etc/ansible/ansible.cfg
```
Uncomment # host_key_checking = False
Ansible ping test
```shell
ansible controller  -m ping
```
Ansible script module 

Execute bash scripts on a group of remote hosts
```shell
ansible controller -m script -a "path-to-your-local-script" (--sudo) 
```
Execute shell commands on remote hosts
```shell
ansible controller -m shell -a "sudo systemctl restart openstack-aodh-notifier"
```
