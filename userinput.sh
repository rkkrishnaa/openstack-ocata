#User input parameters
HOST='controller'
PUBLIC_INTERFACE_NAME='eth0'
export ip=$(/sbin/ifconfig $PUBLIC_INTERFACE_NAME | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
OVERLAY_INTERFACE_IP_ADDRESS=$ip
PROVIDER_INTERFACE_NAME=$PUBLIC_INTERFACE_NAME
REGION='RegionOne'
#DB Passwords
DBPASS='password'
KEYSTONE_DBPASS='password'
GLANCE_DBPASS='password'
NOVA_DBPASS='password'
NEUTRON_DBPASS='password'
CINDER_DBPASS='password'
HEAT_DBPASS='password'
CEILOMETER_DBPASS='password'
#Rabbit MQ Password
RABBIT_PASS='password'
#Openstack User Passwords
GLANCE_PASS='password'
NOVA_PASS='password'
PLACEMENT_PASS='password'
NEUTRON_PASS='password'
METADATA_SECRET='password'
CINDER_PASS='password'
HEAT_PASS='password'
CEILOMETER_PASS='password'
ADMIN_PASS='password'
DEMO_PASS='password'
NTP_SERVER_CONTROLLER_NODE='in.pool.ntp.org'
NTP_SERVER_COMPUTE_NODE='controller'
