#!/bin/bash

# on undercloud
# to do some pre-config for overcloud

cd ~
source ./overcloudrc

# variables (default values given)
test_zhian_ip=192.168.37.200
test_hou_net=192.168.22.0/24
new_instance_image=trusty

# add images
for image in $( ls ./images ); do
        glance image-create --name $image --file images/$image \
            --disk-format qcow2 --container-format bare --progress
done

# add flavors
nova flavor-create --ephemeral 0 --is-public True m1.tiny 1 1024 10 1
nova flavor-create --ephemeral 0 --is-public True m1.small 2 2048 20 1
nova flavor-create --ephemeral 0 --is-public True m1.medium 3 4096 40 2
nova flavor-create --ephemeral 0 --is-public True m1.large 4 8192 80 4

# add key pair
nova keypair-add newbie_test > newbie_test.pem
## change the attribute or `ssh` will fail
chmod 700 ./newbie_test.pem

# create network
neutron net-create test_hou
neutron subnet-create test_hou $test_hou_net --name test_hou_sub --dns-nameserver 8.8.8.8

# add router
neutron router-create router_test_hou
router_id=$(openstack router list | grep router_test_hou | cut -d'|' -f 2)
external_network_id=$(openstack network list | grep external | cut -d'|' -f 2)
hou_subnet_id=$(openstack network list | grep test_hou | cut -d'|' -f 4)
neutron router-gateway-set $router_id $external_network_id
neutron router-interface-add $router_id $hou_subnet_id
neutron port-create test_hou

# create instance of Ubuntu 14.04
instance_img_id=$(openstack image list | grep $new_instance_image | cut -d'|' -f 2)
nova boot --flavor 2 --image $instance_img_id \
    --key-name newbie_test --security-groups default \
    --description "newbie_test" test_zhian

# add floating ip
openstack floating ip create --floating-ip-address $test_zhian_ip external
nova floating-ip-associate test_zhian $test_zhian_ip

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
ssh-keygen -R $test_zhian_ip
echo  '#!/bin/bash' > newbie.sh
echo -e "\n" >> newbie.sh
echo "ssh -i ./newbie_test.pem ubuntu@192.168.32.200" >> newbie.sh
chmod +x ./newbie.sh

scp -i ./newbie_test.pem overcloudrc ubuntu@192.168.32.200:~/

# change the quota
## increase limit of the number of instances
openstack quota set admin --instances 30
## increase limit of the number of CPU
openstack quota set admin --cores 30