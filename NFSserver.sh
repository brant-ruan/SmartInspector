#!/bin/bash

# on one controller node
# configure NFS Server

mkdir -p /var/lib/nova/instances/

echo "/var/lib/nova/instances 192.0.2.0/24(rw,sync,no_root_squash,insecure)" \
>> /etc/exports

exportfs -rv

chmod o+x /var/lib/nova/instances

sed -i "s|^#Nobody-User.*$|Nobody-User = nobody|" \
/etc/idmapd.conf
sed -i "s|^#Nobody-Group.*$|Nobody-Group = nobody|" \
/etc/idmapd.conf

sed -i "s|^#listen_tls =.*$|listen_tls = 0|" \
/etc/libvirt/libvirtd.conf
sed -i "s|^#listen_tcp =.*$|listen_tcp = 1|" \
/etc/libvirt/libvirtd.conf

sed -i 's|^#auth_tcp = .*$|auth_tcp = "none"|' \
/etc/libvirt/libvirtd.conf

