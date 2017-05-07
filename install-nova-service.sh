#Openstack Ocata bash script installation
#Bash script to install and configure openstack nova.

source userinput.sh
source admin-openrc

#mysql database for openstack nova 
mysql -u root -p$DBPASS << EOF
CREATE DATABASE nova_api;
CREATE DATABASE nova;
CREATE DATABASE nova_cell0;
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' \
  IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' \
  IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' \
  IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' \
  IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' \
  IDENTIFIED BY '$NOVA_DBPASS';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' \
  IDENTIFIED BY '$NOVA_DBPASS';
EOF

#install and configure openstack nova service
openstack user create \
 	--domain default \
 	--password $NOVA_PASS nova
openstack role add --project \
	service --user nova admin
openstack service create \
	--name nova \
	--description "OpenStack Compute" compute
openstack endpoint create \
	--region $REGION compute public http://controller:8774/v2.1
openstack endpoint create \
	--region $REGION compute internal http://controller:8774/v2.1
openstack endpoint create \
	--region $REGION compute admin http://controller:8774/v2.1
openstack user create \
	--domain default \
	--password $PLACEMENT_PASS placement
openstack role add \
	--project service \
	--user placement admin
openstack service create \
	--name placement \
	--description "Placement API" placement
openstack endpoint create \
	--region $REGION placement public http://controller:8778
openstack endpoint create \
	--region $REGION placement internal http://controller:8778
openstack endpoint create \
	--region $REGION placement admin http://controller:8778

apt install nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler nova-placement-api -y
cp /etc/nova/nova.conf /etc/nova/nova.$(date '+%m.%d.%Y.%H:%M:%S').conf
crudini --set /etc/nova/nova.conf api_database connection mysql+pymysql://nova:$NOVA_DBPASS@controller/nova_api
crudini --set /etc/nova/nova.conf database connection mysql+pymysql://nova:$NOVA_DBPASS@controller/nova
crudini --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:$RABBIT_PASS@controller
crudini --set /etc/nova/nova.conf DEFAULT my_ip  $ip
crudini --set /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf api auth_strategy keystone
crudini --set /etc/nova/nova.conf vnc enabled true
crudini --set /etc/nova/nova.conf vnc vncserver_listen '$my_ip'
crudini --set /etc/nova/nova.conf vnc vncserver_proxyclient_address '$my_ip'
crudini --set /etc/nova/nova.conf glance api_servers http://controller:9292
crudini --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
crudini --set /etc/nova/nova.conf placement os_region_name $REGION
crudini --set /etc/nova/nova.conf placement project_domain_name Default
crudini --set /etc/nova/nova.conf placement project_name service
crudini --set /etc/nova/nova.conf placement auth_type password
crudini --set /etc/nova/nova.conf placement user_domain_name Default
crudini --set /etc/nova/nova.conf placement auth_url http://controller:35357/v3
crudini --set /etc/nova/nova.conf placement username placement
crudini --set /etc/nova/nova.conf placement password $PLACEMENT_PASS
crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name default
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name default
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password $NOVA_PASS



su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova

su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova

#start nova services 
service nova-api restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

#add nova-compute service
bash addcomputenode.sh
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

#verify nova installation
openstack compute service list
openstack catalog list
openstack image list
