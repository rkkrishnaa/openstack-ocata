#!/usr/bin/env/python
#Python script to stop all instances under the tenants owned by the user
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
vmid = [vms for vms in nova.servers.list(search_opts={'status': 'ACTIVE', 'all_tenants': '1'})]
for vm in vmid:
	nova.servers.stop(vm)
	print 'stopped:', vm
