#!/bin/bash

# pre-configuration for cloudify&clearwater deployment
# to do some pre-config for overcloud

cd ~
source ./overcloudrc

# variables (default values given here)
your_network_name=test_zhian
your_subnet_name=test_hou_sub
your_VM_ip=192.168.32.200
your_network_address=192.168.22.0/24
your_router_name=router_test_hou
your_ssh_key_name=newbie
new_instance_image=trusty

# add images
for image in $( ls ./images ); do
        glance image-create --name $image --file images/$image \
            --disk-format qcow2 --container-format bare --progress
done

# add flavors
nova flavor-create --ephemeral 0 --is-public True m1.tiny 1 1024 10 1
nova flavor-create --ephemeral 0 --is-public True m1.small 2 3072 20 1
nova flavor-create --ephemeral 0 --is-public True m1.medium 3 4096 40 2
nova flavor-create --ephemeral 0 --is-public True m1.large 4 8192 80 4

# add key pair
nova keypair-add $your_ssh_key_name > $your_ssh_key_name.pem
## change the attribute or `ssh` will fail
chmod 700 ./$your_ssh_key_name.pem

# create network
neutron net-create $your_network_name
neutron subnet-create $your_network_name $your_network_address --name $your_subnet_name --dns-nameserver 8.8.8.8

# add router
neutron router-create $your_router_name
router_id=$(openstack router list | grep $your_router_name | cut -d'|' -f 2)
external_network_id=$(openstack network list | grep external | cut -d'|' -f 2)
hou_subnet_id=$(openstack network list | grep $your_network_name | cut -d'|' -f 4)
neutron router-gateway-set $router_id $external_network_id
neutron router-interface-add $router_id $hou_subnet_id
neutron port-create $your_network_name

# create instance of Ubuntu 14.04
flavor_id=$(openstack flavor list | grep "small" | cut -d'|' -f 2)
instance_img_id=$(openstack image list | grep $new_instance_image | cut -d'|' -f 2)
nova boot --flavor $flavor_id --image $instance_img_id \
    --key-name $your_ssh_key_name --security-groups default \
    --description "$your_ssh_key_name" test_zhian

# add floating ip
openstack floating ip create --floating-ip-address $your_VM_ip external
nova floating-ip-associate test_zhian $your_VM_ip

# modify security group
sec_grp_prj=$(openstack project list | grep admin | cut -d'|' -f 2)
sec_grp_id=$(openstack security group list | grep $sec_grp_prj | grep default | cut -d'|' -f 2)
## allow ssh
openstack security group rule create  $sec_grp_id --protocol tcp --dst-port 22:22 --src-ip 0.0.0.0/0
## allow ping
openstack security group rule create --protocol icmp $sec_grp_id
## allow any
nova secgroup-add-rule $sec_grp_id tcp 1 65535 0.0.0.0/0

# create ssh login file
ssh-keygen -R $your_VM_ip
echo  '#!/bin/bash' > $your_ssh_key_name.sh
echo -e "\n" >> $your_ssh_key_name.sh
echo "ssh -i ./$your_ssh_key_name.pem ubuntu@192.168.32.200" >> $your_ssh_key_name.sh
chmod +x ./$your_ssh_key_name.sh

# change  default openstack quota
## increase limit of the number of instances
openstack quota set admin --instances 30
## increase limit of the number of CPU
openstack quota set admin --cores 30
# wait virtual machine to start normally, time spent to boot a VM may depend your environment, 20s may be too short if you can't afford a good machine
sleep 20
scp -i ./$your_ssh_key_name.pem overcloudrc ubuntu@$your_VM_ip:~/