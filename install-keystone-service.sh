source userinput.sh
source admin-openrc
mysql -u root -p$DBPASS << EOF
create database keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' \
IDENTIFIED BY '$KEYSTONE_DBPASS';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' \
IDENTIFIED BY '$KEYSTONE_DBPASS';
EOF
apt install keystone -y 
cp /etc/keystone/keystone.conf /etc/keystone/keystone.$(date '+%m.%d.%Y.%H:%M:%S').conf
crudini --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:$KEYSTONE_DBPASS@controller/keystone
crudini --set /etc/keystone/keystone.conf token provider fernet
su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup \
	--keystone-user keystone \
	--keystone-group keystone
keystone-manage credential_setup \
	--keystone-user keystone \
	--keystone-group keystone
keystone-manage bootstrap \
	--bootstrap-password $ADMIN_PASS \
	--bootstrap-admin-url http://controller:35357/v3/ \
	--bootstrap-internal-url http://controller:5000/v3/ \
	--bootstrap-public-url http://controller:5000/v3/ \
	--bootstrap-region-id $REGION
cp /etc/apache2/apache2.conf /etc/apache2/apache2.$(date '+%m.%d.%Y.%H:%M:%S').conf 
sed -i '70i ServerName controller' /etc/apache2/apache2.conf
service apache2 restart
rm -f /var/lib/keystone/keystone.db

openstack project create \
	--domain default \
	--description "Service Project" service
openstack project create \
	--domain default \
	--description "Demo Project" demo
openstack user create \
	--domain default \
	--password $DEMO_PASS  demo
openstack role create user
openstack role add \
	--project demo \
	--user demo user


openstack token issue
source demo-openrc
openstack token issue
