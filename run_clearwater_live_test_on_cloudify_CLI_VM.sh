#!/bin/bash

# on your cloudify CLI VM, we use opnfv/functest container because all dependancies are already installed in docker image

# install docker on this VM
curl -sSL https://get.docker.com/ | sh
# download opnfv docker image
# if some error occurs like this, 'Got permission denied while trying to connect to the Docker daemon socket'
# fix by adding the current user to the docker group: sudo usermod -a -G docker $USER
# log out of your account and then back log in
docker pull opnfv/functest:danube.2.0
# run the docker container
docker run --dns=192.168.32.201 -it opnfv/functest:danube.2.0 /bin/bash
# launch the test
cd ~/repos/vnfs/vims-test
source /etc/profile.d/rvm.sh
rake test[clearwater.opnfv] SIGNUP_CODE=secret
# after this,you should be able to see the test results no console
