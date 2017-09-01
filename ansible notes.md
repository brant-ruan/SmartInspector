# Ansible

ansible default configuration file path /etc/ansible

An example hosts file looks like:

```
[controller]
192.0.2.6  ansible_ssh_user=heat-admin
192.0.2.10 ansible_ssh_user=heat-admin
192.0.2.3  ansible_ssh_user=heat-admin
```
Ansible ping test
```shell
ansible controller  -m ping
```

