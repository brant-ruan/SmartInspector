#!/bin/bash

# on one controller node
# bash script to configure NFS Server, execute on controller nodes

mkdir -p /var/lib/nova/instances/

echo "/var/lib/nova/instances 192.0.2.0/24(rw,sync,no_root_squash,insecure)" \
>> /etc/exports

exportfs -rv

chmod o+x /var/lib/nova/instances

sed -i "s|^#Nobody-User.*$|Nobody-User = nobody|" \
/etc/idmapd.conf
sed -i "s|^#Nobody-Group.*$|Nobody-Group = nobody|" \
/etc/idmapd.conf

# /etc/libvirt/libvirtd.conf
sed -i "s|^#listen_tls =.*$|listen_tls = 0|" \
/etc/libvirt/libvirtd.conf
sed -i "s|^#listen_tcp =.*$|listen_tcp = 1|" \
/etc/libvirt/libvirtd.conf
sed -i 's|^#auth_tcp = .*$|auth_tcp = "none"|' \
/etc/libvirt/libvirtd.conf
sed -i 's|^#unix_sock_group = .*$|unix_sock_group= "libvirtd"|' \
/etc/libvirt/libvirtd.conf
sed -i 's|^#unix_sock_ro_perms = .*$|unix_sock_ro_perms= "0777"|' \
/etc/libvirt/libvirtd.conf
sed -i 's|^#unix_sock_rw_perms = .*$|unix_sock_rw_perms= "0770"|' \
/etc/libvirt/libvirtd.conf
sed -i 's|^#auth_unix_ro = .*$|auth_unix_ro= "none"|' \
/etc/libvirt/libvirtd.conf
sed -i 's|^#auth_unix_rw = .*$|auth_unix_rw= "none"|' \
/etc/libvirt/libvirtd.conf

# configure qemu
# /etc/libvirt/qemu.conf
sed -i 's|^#vnc_listen = .*$|vnc_listen= "0.0.0.0"|' \
/etc/libvirt/qemu.conf
sed -i 's|^#user = .*$|user= "root"|' \
/etc/libvirt/qemu.conf
sed -i 's|^#group = .*$|group= "root"|' \
/etc/libvirt/qemu.conf
sed -i 's|^#dynamic_ownership = .*$|dynamic_ownership= "0"|' \
/etc/libvirt/qemu.conf

# restart service to make changes take effect
systemctl restart rpcidmapd.service
systemctl restart nfs-server.service




