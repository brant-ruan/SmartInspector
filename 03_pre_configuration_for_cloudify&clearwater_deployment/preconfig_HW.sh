#!/bin/bash

# on your JumpHost,HW machine, upload images to undercloud 
stack_ip=192.0.2.1
ssh-keygen -R $stack_ip
# disable ssh host key checking, you don't have to type yes the first time
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r images/ stack@$stack_ip:~/