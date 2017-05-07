#Openstack Ocata bash script installation
#It is a main installer file all other scripts are invoked from here.

source userinput.sh
#install and configure basic services
#Mysql server, Rabbit MQ server, Memcached server and NTP server
bash install-basic-services.sh 
#install and configure openstack keystone service
bash install-keystone-service.sh


#install and configure openstack glance service
if [ $INSTALL_GLANCE == 'yes' ]
  then
    bash install-glance-service.sh
fi

#install and configure openstack nova service
if [ $INSTALL_NOVA == 'yes' ]
  then
    bash install-nova-service.sh
fi

#install and configure openstack nova service
if [ $INSTALL_NEUTRON == 'yes' ]
  then
bash install-neutron-service.sh
fi

#install and configure openstack horizon
if [ $INSTALL_HORIZON == 'yes' ]
  then
  bash install-horizon.sh
fi

#verify openstack installation
#create tenant nework and launch instance
bash post-installation.sh
