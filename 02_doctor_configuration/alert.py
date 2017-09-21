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
import identity_auth

class Alert(object):

    event_type = "compute.host.down"

    def __init__(self, args):

        self.hostname = args.hostname
        print ("hostname:",self.hostname)
        self.ip_addr = args.ip or socket.gethostbyname(self.hostname)
        print ("ip_addr",self.ip_addr)

        auth=identity_auth.get_identity_auth()
        sess=session.Session(auth=auth)
        congress = client.Client(session=sess, service_type='policy')
        ds = congress.list_datasources()['results']
        doctor_ds = next((item for item in ds if item['driver'] == 'doctor'),
                            None)
        congress_endpoint = congress.httpclient.get_endpoint(auth=auth)
        self.inspector_url = ('%s/v1/data-sources/%s/tables/events/rows' %
                                (congress_endpoint, doctor_ds['id']))

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
            'X-Auth-Token':self.session.get_token(),
        }
        requests.put(self.inspector_url, data=data, headers=headers)
        print ("alert")


def get_args():
    parser = argparse.ArgumentParser(description='Doctor Sample Monitor')
    parser.add_argument('hostname', metavar='HOSTNAME', type=str, nargs='?',
                        help='a hostname to monitor connectivity')
    parser.add_argument('ip', metavar='IP', type=str, nargs='?',
                        help='an IP address to monitor connectivity')
    return parser.parse_args()

def main():
    args = get_args()
    alert = Alert(args)
    alert.report_error()

if __name__ == '__main__':
    main()
