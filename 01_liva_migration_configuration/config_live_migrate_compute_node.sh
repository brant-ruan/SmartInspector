#!/bin/bash

#author : zang yuan
#this script is used to config live-migration on compute node
# run as root user

# $1 is nfs-server's ip

yum install nfs-utils

mount $1:/var/lib/nova/instances /var/lib/nova/instances 

echo "$1:/var/lib/nova/instances /var/lib/nova/instances nfs defaults 0 0" >> /etc/fstab

mount -a -v 

df -k

ls -ld /var/lib/nova/instances 

chmod 777 /var/lib/nova/instances 

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

usermod nova -a -G libvirt

#config /etc/nova/nova.conf [libvirt]

#live_migration_flag=VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_TUNNELLED

sed -i "62 ilive_migration_flag=VIR_MIGRATE_UNDEFINE_SOURCE,VIR_MIGRATE_PEER2PEER,VIR_MIGRATE_LIVE,VIR_MIGRATE_TUNNELLED" /etc/nova/nova.conf

systemctl restart libvirtd.service

systemctl restart openstack-nova-compute




