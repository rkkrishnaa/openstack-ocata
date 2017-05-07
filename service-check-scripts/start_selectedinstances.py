#!/usr/bin/env/python
#Python script to start selected instances under the tenants owned by the user
#Export environment variables before executing the script

import os
from novaclient import client as novaclient
def get_nova_creds():
    d = {}
    d['username'] = os.environ['OS_USERNAME']
    d['api_key'] = os.environ['OS_PASSWORD']
    d['auth_url'] = os.environ['OS_AUTH_URL']
    d['project_id'] = os.environ['OS_TENANT_NAME']
    return d
creds = get_nova_creds()
nova = novaclient.Client("2", **creds)
instance_id = ['62a14c7e-f8a9-4af3-bea2-50e77c23be6c', 'a601dc6b-6fcf-4831-a1d3-379786329678',
               '176adff0-4508-42d4-b1ae-24a7542c79e3']
for vmid in instance_id:
        nova.servers.start(vmid)
        print 'started:', vmid
