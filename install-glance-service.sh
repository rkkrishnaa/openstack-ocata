#Openstack Ocata bash script installation
#Bash script to install and configure openstack glance.

source userinput.sh
source admin-openrc

#mysql database for openstack glance
mysql -u root -p$DBPASS << EOF
create database glance;
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' \
IDENTIFIED BY '$GLANCE_DBPASS';
GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' \
IDENTIFIED BY '$GLANCE_DBPASS';
EOF

#install and configure glance api and glance registry service
openstack user create \
	--domain default \
	--password $GLANCE_PASS glance
openstack role add \
	--project service \
	--user glance admin
openstack service create \
	--name glance \
	--description "OpenStack Image" image
openstack endpoint create \
	--region $REGION image public http://controller:9292
openstack endpoint create \
	--region $REGION image internal http://controller:9292
openstack endpoint create \
	--region $REGION image admin http://controller:9292

apt install glance -y
cp /etc/glance/glance-api.conf /etc/glance/glance-api.$(date '+%m.%d.%Y.%H:%M:%S').conf
crudini --set /etc/glance/glance-api.conf database connection mysql+pymysql://glance:$GLANCE_DBPASS@controller/glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/glance/glance-api.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/glance/glance-api.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_domain_name default
crudini --set /etc/glance/glance-api.conf keystone_authtoken user_domain_name default
crudini --set /etc/glance/glance-api.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-api.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-api.conf keystone_authtoken password $GLANCE_PASS
crudini --set /etc/glance/glance-api.conf paste_deploy flavor keystone
crudini --set /etc/glance/glance-api.conf glance_store stores file,http
crudini --set /etc/glance/glance-api.conf glance_store default_store file
crudini --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/

cp /etc/glance/glance-registry.conf /etc/glance/glance-registry.$(date '+%m.%d.%Y.%H:%M:%S').conf
crudini --set /etc/glance/glance-registry.conf database connection mysql+pymysql://glance:$GLANCE_DBPASS@controller/glance
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/glance/glance-registry.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/glance/glance-registry.conf keystone_authtoken auth_type password
crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_domain_name default
crudini --set /etc/glance/glance-registry.conf keystone_authtoken user_domain_name default
crudini --set /etc/glance/glance-registry.conf keystone_authtoken project_name service
crudini --set /etc/glance/glance-registry.conf keystone_authtoken username glance
crudini --set /etc/glance/glance-registry.conf keystone_authtoken password $GLANCE_PASS
crudini --set /etc/glance/glance-registry.conf paste_deploy flavor keystone

su -s /bin/sh -c "glance-manage db_sync" glance
service glance-registry restart
service glance-api restart

#verify glance installation
wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
openstack image create "cirros" \
  --file cirros-0.3.5-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public
openstack image list

