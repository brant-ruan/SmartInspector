#!/usr/bin/env python
#author: zangyuan
#date 2017.9.11

import os
import requests
import toml
import json
import time 
import logging

def live_migrate():
    pass 


#read config file 
def read_config():
    dicts = toml.load("monitor-config.toml")
    config = {}
    config["OS_username"] = dicts["OpenStack"]["OS_username"]
    config["OS_password"] = dicts["OpenStack"]["OS_password"]
    config["KeyStoneURL"] = dicts["OpenStack"]["KeyStoneURL"]
    config["CongressURL"] = dicts["OpenStack"]["CongressURL"]
    config["HostName"] = dicts["ComputeNode"]["HostName"]
    config["MonitoredNIC"] = dicts["ComputeNode"]["MonitoredNIC"]

    return config 


#send alarm to congress restful api
def alert(config):
    token = get_token(config)
    sendtime = time.strftime("%Y-%m-%d")+"T"+time.strftime("%H-%M-%S")+"Z"
    details = {'hostname':config["HostName"],'status':"down",'monitor':"DIYMonitor",'monitor_event_id':"111"}
    item = {'time':sendtime,'type':"compute.host.down",'details':details}
    payload = list()
    payload.append(item)
    header = {'X-Auth-Token':token,'Content-Type':'application/json'}
    requests.put(config["CongressURL"]+"/v1/data-sources/doctor/tables/events/rows",data = json.dumps(payload),headers=header)



#get token from keystone service
def get_token(config):
    passwordCredentials = {'username':config["OS_username"], 'password':config["OS_password"]}
    auth = {'tenantName':config["OS_username"],'passwordCredentials':passwordCredentials}
    keystone_data = {'auth':auth}
    r = requests.post(config["KeyStoneURL"]+"/tokens",data = json.dumps(keystone_data))
    res = r.json()
    token = res['access']['token']['id']
    return token 


#
def run():
    config = read_config()
    fault = False
    while True:
        result = os.popen("ethtool "+config["MonitoredNIC"]).readlines()[1]
        if result.find("Link detected: no") and (not fault):
            alert(config)
            fault = True 

        elif (not result.find("Link detected: no")) and (fault):
            fault = False



if __name__ == "__main__":
    run()
    
