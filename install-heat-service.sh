#Openstack Ocata bash script installation
#Bash script to install and configure openstack heat.

source userinput.sh
source admin-openrc

#mysql database for openstack heat
mysql -u root -p$DBPASS << EOF
create database heat;
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'localhost' \
IDENTIFIED BY '$HEAT_DBPASS';
GRANT ALL PRIVILEGES ON heat.* TO 'heat'@'%' \
IDENTIFIED BY '$HEAT_DBPASS';
EOF

#install and configure heat service and heat api endpoints
openstack user create \
			--domain default \
			--password $HEAT_PASS heat
openstack role add \
			--project service \
			--user heat admin
openstack service create \
			--name heat \
			--description "Orchestration" orchestration				
openstack service create \
			--name heat-cfn \
			--description "Orchestration"  cloudformation
openstack endpoint create \
			--region $REGION orchestration public http://controller:8004/v1/%\(tenant_id\)s
openstack endpoint create \
			--region $REGION orchestration internal http://controller:8004/v1/%\(tenant_id\)s
openstack endpoint create \
			--region $REGION orchestration admin http://controller:8004/v1/%\(tenant_id\)s
openstack endpoint create \
			--region $REGION cloudformation public http://controller:8000/v1
openstack endpoint create \
			--region $REGION cloudformation internal http://controller:8000/v1
openstack endpoint create \
			--region $REGION cloudformation admin http://controller:8000/v1
openstack domain create \
			--description "Stack projects and users" heat
openstack user create \
			--domain heat \
			--password $HEAT_PASS heat_domain_admin
openstack role add \
			--domain heat \
			--user-domain heat \
			--user heat_domain_admin admin
openstack role create heat_stack_owner
openstack role create heat_stack_user
openstack role add \
			--project demo \
			--user demo heat_stack_owner

apt-get install heat-api heat-api-cfn heat-engine -y
cp /etc/heat/heat.conf /etc/heat/heat.$(date '+%m.%d.%Y.%H:%M:%S').conf
crudini --set /etc/heat/heat.conf database connection mysql+pymysql://heat:$HEAT_DBPASS@controller/heat
crudini --set /etc/heat/heat.conf DEFAULT transport_url rabbit://openstack:$RABBIT_PASS@controller
crudini --set /etc/heat/heat.conf DEFAULT heat_metadata_server_url http://controller:8000
crudini --set /etc/heat/heat.conf DEFAULT heat_waitcondition_server_url http://controller:8000/v1/waitcondition
crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin heat_domain_admin
crudini --set /etc/heat/heat.conf DEFAULT stack_domain_admin_password $HEAT_PASS 
crudini --set /etc/heat/heat.conf DEFAULT stack_user_domain_name heat
crudini --set /etc/heat/heat.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/heat/heat.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/heat/heat.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/heat/heat.conf keystone_authtoken auth_type password
crudini --set /etc/heat/heat.conf keystone_authtoken project_domain_name default
crudini --set /etc/heat/heat.conf keystone_authtoken user_domain_name default
crudini --set /etc/heat/heat.conf keystone_authtoken project_name service
crudini --set /etc/heat/heat.conf keystone_authtoken username heat
crudini --set /etc/heat/heat.conf keystone_authtoken password $HEAT_PASS
crudini --set /etc/heat/heat.conf trustee auth_type password
crudini --set /etc/heat/heat.conf trustee auth_url http://controller:35357
crudini --set /etc/heat/heat.conf trustee username heat
crudini --set /etc/heat/heat.conf trustee password $HEAT_PASS
crudini --set /etc/heat/heat.conf trustee user_domain_name default
crudini --set /etc/heat/heat.conf clients_keystone auth_uri http://controller:35357
crudini --set /etc/heat/heat.conf ec2authtoken auth_uri http://controller:5000

su -s /bin/sh -c "heat-manage db_sync" heat
service heat-api restart
service heat-api-cfn restart
service heat-engine restart

#verify heat installation
openstack orchestration service list
