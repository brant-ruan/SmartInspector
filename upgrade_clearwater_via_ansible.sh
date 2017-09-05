# this script file should be executed in cloudify manager VM because only cloudify manager VM can access all of the clearwater nodes
# upload cloudify-agent-kp.pem and install ansible and config proper ansible host file, manager VM floating ip: 192.168.32.199 before any other operation
# --------------------command here------------------------
# scp -i cloudify-manager-kp.pem /home/ubuntu/.ssh/cloudify-agent-kp.pem centos@192.168.32.199:~
#---------------------fommand finished--------------------
cd ~
sudo chmod +x cloudify-agent-kp.pem
sudo yum install epel-release -y
sudo yum update -y
sudo yum install ansible -y


# after install ansible, config ansible hosts file, your hosts file should looks like this
# remove comments
# [clearwater-hosts]
# 10.67.79.16 ansible_ssh_user=ubuntu
# 10.67.79.13 ansible_ssh_user=ubuntu
# 10.67.79.12 ansible_ssh_user=ubuntu
# 10.67.79.15 ansible_ssh_user=ubuntu
# 10.67.79.5  ansible_ssh_user=ubuntu
# 10.67.79.14 ansible_ssh_user=ubuntu
# 10.67.79.7  ansible_ssh_user=ubuntu
# 10.67.79.4  ansible_ssh_user=ubuntu
# make sure ansible works properly with clearwater hosts
# ansible clearwater-hosts -m ping --private-key cloudify-agent-kp.pem
# you should see all green output

# upgrade clearwater
ansible clearwater-hosts -m shell -a 'sudo clearwater-upgrade' --private-key cloudify-agent-kp.pem


