#Openstack Ocata bash script installation.
#In this section you are requested to enter the input parameters required for openstack installation.
#Edit this file carefully to avoid configuration error in openstack services.

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

#NTP 
NTP_SERVER_CONTROLLER_NODE='in.pool.ntp.org'
NTP_SERVER_COMPUTE_NODE='controller'

#Deployment options
#Basic supporting services and keystone is mandatory, it will be installed. Remaining service installation are optional and it depends on your use case 

INSTALL_GLANCE='yes'
INSTALL_NOVA='yes'
INSTALL_NEUTRON='yes'
INSTALL_CINDER='no'
INSTALL_HEAT='no'
INSTALL_SWIFT='no'
INSTALL_HORIZON='yes'

