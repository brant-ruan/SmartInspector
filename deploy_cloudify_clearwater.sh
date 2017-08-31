#!/bin/bash

# on test_zhian
# deploy cloudify and clearwater

cd ~

# install virtualenv
sudo apt-get update
sudo apt-get install git python-pip python-dev python-virtualenv -y \
&& sudo apt-get install nova-console -y \
&& sudo apt-get install python-novaclient -y \
&& sudo apt-get install python-openstackclient -y

virtualenv cloudify
source cloudify/bin/activate

# install cloudify
cd cloudify
pip install cloudify==3.3.1
mkdir -p cloudify-manager
cd cloudify-manager
git clone -b 3.3.1-build  https://github.com/boucherv-orange/cloudify-manager-blueprints.git

# initialize cfy work environment (initializes CLI configuration files)
cfy init
cd cloudify-manager-blueprints/
cfy local create-requirements -o requirements.txt -p openstack-manager-blueprint.yaml
sudo pip install -r requirements.txt
# prepare for bootstrap manager on top of openstack

# provide your own openstack information
## information from ~/overcloudrc
if [ -e ~/overcloudrc ]; then
source ~/overcloudrc
m_keystone_password=$(cat ~/overcloudrc | grep 'OS_PASSWORD' | cut -d'=' -f 2)
m_keystone_url=$(cat ~/overcloudrc | grep 'OS_AUTH_URL' | cut -d'=' -f 2)
#m_region=$(openstack endpoint show keystone | grep region | cut -d'|' -f 3)
#m_region=$(echo $m_region) # to strip the whitespaces
m_region="regionOne"
m_image_id=$(openstack image list | grep -i centos | cut -d'|' -f 2)
m_image_id=$(echo $m_image_id)
m_flavor_id=$(nova flavor-list | grep large | cut -d'|' -f 2)
m_flavor_id=$(echo $m_flavor_id)

# keystone_username
sed -i "s|^keystone_username:.*$|keystone_username: 'admin'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "keystone_username: admin"
# keystone_password
sed -i "s|^keystone_password:.*$|keystone_password: '$m_keystone_password'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "keystone_password: $m_keystone_password"
# keystone_tenant_name
sed -i "s|^keystone_tenant_name:.*$|keystone_tenant_name: 'admin'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "keystone_tenant_name: admin"
# keystone_url
sed -i "s|^keystone_url:.*$|keystone_url: '$m_keystone_url'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "keystone_url: $m_keystone_url"
# region
sed -i "s|^region:.*$|region: '$m_region'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "region: $m_region"
# ssh_key_filename
sed -i "s|^#ssh_key_filename:.*$|ssh_key_filename: ~/.ssh/cloudify-manager-kp.pem|" \
openstack-manager-blueprint-inputs.yaml
echo -e "ssh_key_filename: ~/.ssh/cloudify-manager-kp.pem"
# agent_private_key_path
sed -i "s|^#agent_private_key_path:.*$|agent_private_key_path: ~/.ssh/cloudify-agent-kp.pem|" \
openstack-manager-blueprint-inputs.yaml
echo -e "agent_private_key_path: ~/.ssh/cloudify-agent-kp.pem"
# manager_public_key_name
sed -i "s|^#manager_public_key_name:.*$|manager_public_key_name: 'manager_public_key'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "manager_public_key_name: 'manager_public_key'"
# agent_public_key_name
sed -i "s|^#agent_public_key_name:.*$|agent_public_key_name: 'agent_public_key'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "agent_public_key_name: 'agent_public_key'"
# image id
sed -i "s|^image_id:.*$|image_id: '$m_image_id'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "image_id: '$m_image_id'"
# flavor id
sed -i "s|^flavor_id:.*$|flavor_id: '$m_flavor_id'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "flavor_id: '$m_flavor_id'"
# external
sed -i "s|^external_network_name:.*$|external_network_name: 'external'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "external_network_name: 'external'"
# agents_user
sed -i "s|^agents_user:.*$|agents_user: 'ubuntu'|" \
openstack-manager-blueprint-inputs.yaml
echo -e "agents_user: 'ubuntu'\n"
echo -e "openstack-manager-blueprint-inputs.yaml modified. Succeed.\n"
else
echo -e "~/overcloudrc does not exist.\n"
exit
fi

# bootstrap manager
## first it will install plugins
cfy bootstrap --install-plugins -p openstack-manager-blueprint.yaml \
-i openstack-manager-blueprint-inputs.yaml
## second it will bootstrap the manager actually
cfy bootstrap --install-plugins -p openstack-manager-blueprint.yaml \
-i openstack-manager-blueprint-inputs.yaml

# deploy clearwater by cloudify
cd ~/cloudify/cloudify-manager/
mkdir blueprints
cd blueprints
git clone -b stable https://github.com/Orange-OpenSource/opnfv-cloudify-clearwater.git
cd opnfv-cloudify-clearwater

# upload clearwater blueprint
cfy blueprints upload -b clearwater-3.3 -p openstack-blueprint.yaml

# begin to deploy clearwater
m_cw_image_id=$(openstack image list | grep -i trusty | cut -d'|' -f 2)
m_cw_image_id=$(echo $m_cw_image_id)
m_cw_flavor_id=$(nova flavor-list | grep small | cut -d'|' -f 2)
m_cw_flavor_id=$(echo $m_cw_flavor_id)
m_cw_agent_user='ubuntu'
m_cw_external_network_name='external'
m_cw_public_domain='clearwater.opnfv'

# provide inputs information
cp inputs/openstack.yaml.template inputs/inputs.yaml
echo -e "image_id: '$m_cw_image_id'\n" > inputs/inputs.yaml
echo -e "flavor_id: '$m_cw_flavor_id'\n" >> inputs/inputs.yaml
echo -e "agent_user: '$m_cw_agent_user'\n" >> inputs/inputs.yaml
echo -e "external_network_name: '$m_cw_external_network_name'\n" >> inputs/inputs.yaml
echo -e "public_domain: '$m_cw_public_domain'\n" >> inputs/inputs.yaml

cfy deployments create -b clearwater-3.3 -d clearwater-test --inputs inputs/inputs.yaml

cfy executions start -w install -d clearwater-test