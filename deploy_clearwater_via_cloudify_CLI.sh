#!/bin/bash

# on test_zhian
# deploy clearwater via cloudify CLI 3.3.1
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