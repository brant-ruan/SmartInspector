#!/usr/bin/env python
#author : zangyuan
#2017.9.26

from flask import Flask 
from flask import request
import json
import requests
import logging
import toml
import os 



CONFIG = read_config()

def live_migrate_via_rest(vm_instance_id,config):
    token = get_token(config)
    nova_action_url = config['NOVAURL'] + '/servers/' + instance_id +'/action'
    os_migrateLive = {'host':None,'block_migration':'auto'}
    payload = {'os-migrateLive':os_migrateLive}
    header = {'X-Auth-Token':token,'Content-Type':'application/json'}
    requests.post(nova_action_url,data = json.dumps(payload),headers = header)


def live_migrate_via_cmd(vm_instance_id,target_host_id):
    os.system("source overcloudrc && nova live-migration "+vm_instance_id+" "+target_host_id)
    
    


def evacuate():
    pass 


def notify():
    pass



def get_vm_instance_id(alarm_data):
    reason_data = alarm_data['reason_data']
    event = reason_data['event']
    traits = event['traits']
    for item in traits:
        if item[0] == "instance_id":
            return item[2]

        else:
            return None


def get_token():
    passwordCredentials = {'username':config["OS_USERNAME"], 'password':config["OS_PASSWORD"]}
    auth = {'tenantName':config["OS_USERNAME"],'passwordCredentials':passwordCredentials}
    keystone_data = {'auth':auth}
    r = requests.post(config["KEYSTONEURL"]+"/tokens",data = json.dumps(keystone_data))
    res = r.json()
    token = res['access']['token']['id']
    return token



def read_config():
    dicts = toml.load("manager-config.toml")
    config = {}
    config["OS_USERNAME"] = dicts["OS_USERNAME"]
    config["OS_PASSWORD"] = dicts["OS_PASSWORD"]
    config["KEYSTONEURL"] = dicts["KEYSTONEURL"]
    config["NOVAURL"] = dicts["NOVAURL"]
    config["PORT"]

    return config 



app = Flask(__name__)

@app.route('/',methods=['POST'])
def listen():

    logging.basicConfig(filename="manager.log",level=logging.INFO,format='%(asctime)s  %(message)s')

    logging.warn("manager receive alarm request from aodh webhook notifier!")
    
    vm_instance_id = get_vm_instance_id(request.json)

    if vm_instance_id != None:
        print "vm instance id : "+vm_instance_id+" need to be migrated!"
        logging.warn("vm instance id : "+vm_instance_id+" need to be migrated!")
        live_migrate_via_rest(vm_instance_id,CONFIG)
        logging.warn("manager execute live_migration on vm_instance_id : "+vm_instance_id)
        return "success"


    else:
        return None





if __name__ == "__main__":
    config = read_config()
    app.run(port=CONFIG['PORT'])