#Openstack Ocata bash script installation
#Bash script to install and configure openstack compute node.

source userinput.sh
source admin-openrc
export ip=$(/sbin/ifconfig $PUBLIC_INTERFACE_NAME | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
echo "$controllerip controller" >> /etc/hosts

apt update
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy upgrade
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy dist-upgrade
apt install software-properties-common -y
add-apt-repository cloud-archive:ocata -y
apt update && apt dist-upgrade -y
apt install python-openstackclient crudini -y

apt install nova-compute -y
apt install neutron-linuxbridge-agent -y

#install ntp server
apt install chrony -y
cp /etc/chrony/chrony.conf /etc/chrony/chrony.$(date '+%m.%d.%Y.%H:%M:%S').conf
sudo sed -i "20i server $NTP_SERVER_COMPUTE_NODE iburst" /etc/chrony/chrony.conf
sudo sed -i '/debian.pool.ntp.org/d' /etc/chrony/chrony.conf
service chrony restart

#install and configure compute service
cp /etc/nova/nova.conf /etc/nova/nova.$(date '+%m.%d.%Y.%H:%M:%S').conf 
crudini --set /etc/nova/nova.conf DEFAULT transport_url rabbit://openstack:$RABBIT_PASS@controller
crudini --set /etc/nova/nova.conf DEFAULT my_ip $ip
crudini --set /etc/nova/nova.conf DEFAULT use_neutron True
crudini --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
crudini --set /etc/nova/nova.conf api auth_strategy keystone
crudini --set /etc/nova/nova.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/nova/nova.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/nova/nova.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/nova/nova.conf keystone_authtoken auth_type password
crudini --set /etc/nova/nova.conf keystone_authtoken project_domain_name default
crudini --set /etc/nova/nova.conf keystone_authtoken user_domain_name default
crudini --set /etc/nova/nova.conf keystone_authtoken project_name service
crudini --set /etc/nova/nova.conf keystone_authtoken username nova
crudini --set /etc/nova/nova.conf keystone_authtoken password $NOVA_PASS
crudini --set /etc/nova/nova.conf vnc enabled True
crudini --set /etc/nova/nova.conf vnc vncserver_listen 0.0.0.0
crudini --set /etc/nova/nova.conf vnc vncserver_proxyclient_address '$my_ip'
crudini --set /etc/nova/nova.conf vnc novncproxy_base_url http://$ip:6080/vnc_auto.html
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

echo "Your cpu info" 
cpuinfo=$(egrep -c '(vmx|svm)' /proc/cpuinfo)
echo $cpuinfo
if [ $cpuinfo != 0 ]
then
	echo "Your hardware supports virtualization"
	crudini --set /etc/nova/nova-compute.conf libvirt virt_type kvm
else
	echo "Your hardware does not supports virtualization"
	crudini --set /etc/nova/nova-compute.conf libvirt virt_type qemu
fi 

service nova-compute restart
openstack hypervisor list

crudini --set /etc/nova/nova.conf neutron url http://controller:9696
crudini --set /etc/nova/nova.conf neutron auth_url http://controller:35357
crudini --set /etc/nova/nova.conf neutron auth_type password
crudini --set /etc/nova/nova.conf neutron project_domain_name default
crudini --set /etc/nova/nova.conf neutron user_domain_name default
crudini --set /etc/nova/nova.conf neutron region_name $REGION
crudini --set /etc/nova/nova.conf neutron project_name service
crudini --set /etc/nova/nova.conf neutron username neutron
crudini --set /etc/nova/nova.conf neutron password $NEUTRON_PASS
crudini --set /etc/nova/nova.conf neutron service_metadata_proxy true
crudini --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret $METADATA_SECRET

cp /etc/neutron/neutron.conf /etc/neutron/neutron.$(date '+%m.%d.%Y.%H:%M:%S').conf
crudini --set /etc/neutron/neutron.conf DEFAULT transport_url rabbit://openstack:$RABBIT_PASS@controller
crudini --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone

crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_uri http://controller:5000
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://controller:35357
crudini --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers controller:11211
crudini --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
crudini --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
crudini --set /etc/neutron/neutron.conf keystone_authtoken project_name service
crudini --set /etc/neutron/neutron.conf keystone_authtoken username neutron
crudini --set /etc/neutron/neutron.conf keystone_authtoken password $NEUTRON_PASS

#restart compute and network service in a compute node
service nova-compute restart
service neutron-linuxbridge-agent restart
