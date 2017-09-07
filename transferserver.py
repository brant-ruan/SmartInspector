from flask import Flask 
from flask import request
import json
import requests

keystone_url = "http://192.168.37.17:5000/v2.0/tokens"
tacker_url = "http://192.168.37.17:9890"
nova_url = "http://192.168.37.17:8774/v2.1"
OS_username = "admin"
OS_password = "4MbCBXaqHJmARqpWzFNJFQF2T"

#curl $keystone_url"/tokens" 
#-X POST 
#-H "Content-Type: application/json" 
#-H "Accept: application/json"  
#-d '{"auth": {"tenantName": "admin", "passwordCredentials": {"username": "admin", "password": "eevNrAGtXWKduWD2G2f6uNmWN"}}}'

app = Flask(__name__)

@app.route("/", methods=['POST'])
def transfer():
    #get request data from Aodh HTTP POST Request
    aodh_alarm_data = request.json
    alarm_name = aodh_alarm_data['alarm_name']
   
    alarm_id = aodh_alarm_data['alarm_id']
    
    severity = aodh_alarm_data['severity']
    
    previous = aodh_alarm_data['previous']
    
    current = aodh_alarm_data['current']
    
    reason = aodh_alarm_data['reason']
   
    reason_data = aodh_alarm_data['reason_data']
    


    #access keystone service to get token
    passwordCredentials = {'username':OS_username, 'password':OS_password}
    auth = {'tenantName':OS_username,'passwordCredentials':passwordCredentials}
    keystone_data = {'auth':auth}

    r = requests.post(keystone_url,data = json.dumps(keystone_data))
    res = r.json()
    token = res['access']['token']['id']

    #access nova service
    server_id = ''
    nova_headers = {'X-Auth-Token':token,'Content-Type':'application/json'}
    evacuate = {'host':'b419863b7d814906a68fb31703c0dbd6','adminPass':'MySecretPass','onSharedStorage':False}
    payload = {'evacuate':evacuate}
    requests.post(nova_url,data = json.dumps(payload),headers=nova_headers) 







    







if __name__ == "__main__":
    app.run()