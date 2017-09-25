import argparse
from datetime import datetime
import json
import os
import requests
import socket
import sys
import time

from keystoneauth1 import session
from congressclient.v1 import client
from keystoneauth1.identity import v2
from keystoneauth1.identity import v3

def get_identity_auth():
    auth_url = os.environ['OS_AUTH_URL']
    username = os.environ['OS_USERNAME']
    password = os.environ['OS_PASSWORD']
    user_domain_name = os.environ.get('OS_USER_DOMAIN_NAME')
    project_name = os.environ.get('OS_PROJECT_NAME') or os.environ.get('OS_TENANT_NAME')
    project_domain_name = os.environ.get('OS_PROJECT_DOMAIN_NAME')
    if auth_url.endswith('v3'):
        return v3.Password(auth_url=auth_url,
                           username=username,
                           password=password,
                           user_domain_name=user_domain_name,
                           project_name=project_name,
                           project_domain_name=project_domain_name)
    else:
        return v2.Password(auth_url=auth_url,
                           username=username,
                           password=password,
                           tenant_name=project_name)

class Alert(object):

    event_type = "compute.host.down"

    def __init__(self,args):

        self.hostname = args.hostname
        print ("hostname:",self.hostname)
        self.ip_addr = socket.gethostbyname(self.hostname)
        print ("ip_addr",self.ip_addr)

        auth=get_identity_auth()
        self.sess=session.Session(auth=auth)
        congress = client.Client(session=self.sess, service_type='policy')
        ds = congress.list_datasources()['results']
        doctor_ds = next((item for item in ds if item['driver'] == 'doctor'),
                            None)
        congress_endpoint = congress.httpclient.get_endpoint(auth=auth)
        self.inspector_url = ('%s/v1/data-sources/%s/tables/events/rows' %
                                (congress_endpoint, doctor_ds['id']))
        print ("inspector url:",self.inspector_url)

    def report_error(self):
        payload = [
            {
                'id': 'monitor_sample_id1',
                'time': datetime.now().isoformat(),
                'type': self.event_type,
                'details': {
                    'hostname': self.hostname,
                    'status': 'down',
                    'monitor': 'monitor_sample',
                    'monitor_event_id': 'monitor_sample_event1'
                },
            },
        ]
        data = json.dumps(payload)

        headers = {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-Auth-Token':self.sess.get_token(),
        }
        print ("token:",self.sess.get_token())
        requests.put(self.inspector_url, data=data, headers=headers)
        print ("alert send")

def get_args():
    parser = argparse.ArgumentParser(description='Doctor Sample Alert')
    parser.add_argument('hostname', metavar='HOSTNAME', type=str, nargs='?',
                           help='hostname of a down compute host')
    return parser.parse_args()

def main():
    args=get_args()
    alert = Alert(args)
    alert.report_error()

if __name__ == '__main__':
    main()