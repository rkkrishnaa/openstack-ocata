#This post installation script will create a tenant network and launch vm under the network.

source userinput.sh
source admin-openrc

#openstack network create  --share --external \
#  --provider-physical-network provider \
#  --provider-network-type flat externalnetwork
#openstack subnet create --network externalnetwork \
#  --allocation-pool start=192.168.0.240,end=192.168.0.250 \
#  --dns-nameserver 8.8.8.8 --gateway 192.168.0.1 \
#  --subnet-range 192.168.0.0/24 externalsubnet

#create local network
openstack network create localnetwork
#create local subnet
openstack subnet create --network localnetwork \
  --dns-nameserver 8.8.8.8 --gateway 10.0.0.1 \
  --subnet-range 10.0.0.0/24 localsubnet
#create router and add local network interface to router
openstack router create router
neutron router-interface-add router localsubnet

#neutron router-gateway-set router externalnetwork

#create flavors
openstack flavor create --id 0 --vcpus 1 --ram 512  --disk 1  m1.nano
openstack flavor create --id 1 --vcpus 1 --ram 1024 --disk 10 m1.micro
openstack flavor create --id 2 --vcpus 1 --ram 2048 --disk 10 m1.small

#create security group
openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --dst-port 22 default

#launch instance
LOCAL_NET_ID=$(nova net-list | awk '/ localnetwork / { print $2 }')
openstack server create --flavor m1.nano --image cirros \
  --nic net-id=$LOCAL_NET_ID --security-group default \
  test-instance
