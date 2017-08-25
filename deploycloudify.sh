#!/bin/bash

# on test_zhian
# deploy cloudify

cd ~

# install virtualenv
sudo apt-get update
sudo apt-get install git python-pip python-dev python-virtualenv -y
sudo apt-get install nova-console
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
	
else
	echo -e "~/overcloudrc does not exist.\n"
	exit
fi
vi openstack-manager-blueprint-inputs.yaml


# bootstrap manager
cfy bootstrap --install-plugins -p openstack-manager-blueprint.yaml -i openstack-manager-blueprint-inputs.yaml# deploy clearwater by cloudify
cd ~/cloudify/cloudify-manager/
mkdir blueprints
cd blueprints
git clone -b stable https://github.com/Orange-OpenSource/opnfv-cloudify-clearwater.git
cd opnfv-cloudify-clearwater
cfy blueprints upload -b clearwater-3.3 -p openstack-blueprint.yaml