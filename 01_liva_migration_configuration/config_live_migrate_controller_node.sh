#!/bin/bash

#author : zang yuan
#this script is used to config live-migration on controller node

#  /etc/nova/nova.conf

sudo yum install nfs-utils


echo "/var/lib/nova/instances 192.0.2.0/24(rw,sync,no_root_squash,insecure)" > /etc/exports

exportfs -rv

chmod o+x /var/lib/nova/instances 

#edit /etc/idmapd.conf file                    ok

sed -i "s/#Nobody-User = nobody/Nobody-User = nobody/g" /etc/idmapd.conf

sed -i "s/#Nobody-Group = nobody/Nobody-Group = nobody/g" /etc/idmapd.conf

#edit /etc/libvirt/libvirtd.conf file          ok

sed -i "s/#auth_unix_ro = \"none\"/auth_unix_ro = \"none\"/g" /etc/libvirt/libvirtd.conf

sed -i "s/#auth_unix_rw = \"none\"/auth_unix_rw = \"none\"/g" /etc/libvirt/libvirtd.conf

sed -i "s/#auth_tcp = \"sasl\"/auth_tcp = \"none\"/g" /etc/libvirt/libvirtd.conf

sed -i "s/#unix_sock_rw_perms = \"0770\"/unix_sock_rw_perms = \"0770\"/g" /etc/libvirt/libvirtd.conf

sed -i "s/#unix_sock_ro_perms = \"0777\"/unix_sock_ro_perms = \"0777\"/g" /etc/libvirt/libvirtd.conf

sed -i "s/#unix_sock_group = \"libvirt\"/unix_sock_group = \"libvirt\"/g" /etc/libvirt/libvirtd.conf

sed -i "s/#listen_tcp = 1/listen_tcp = 1/g" /etc/libvirt/libvirtd.conf

sed -i "s/#listen_tls = 0/listen_tls = 0/g" /etc/libvirt/libvirtd.conf

# edit /etc/libvirt/qemu.conf                  ok

sed -i "s/#user = \"root\"/user = \"root\"/g" /etc/libvirt/qemu.conf

sed -i "s/#group = \"root\"/group = \"root\"/g" /etc/libvirt/qemu.conf

sed -i "s/#dynamic_ownership = 1/dynamic_ownership = 0/g" /etc/libvirt/qemu.conf

sed -i "s/#vnc_listen = \"0.0.0.0\"/vnc_listen = \"0.0.0.0\"/g" /etc/libvirt/qemu.conf

chmod 777 /var/lib/nova/instances 

systemctl restart rpcidmapd.service

systemctl restart nfs-server.service



