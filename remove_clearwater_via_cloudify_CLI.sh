#!/bin/bash

# on test_zhian
# remove clearwater deployment via cloudify CLI 3.3.1
cfy executions start -w uninstall-d clearwater-test
