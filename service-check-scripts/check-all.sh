echo "Enter action[start|stop|status|restart]"
read -r action
action=$action

service chrony $action
service mysql $action
service rabbitmq-server $action
service memcached $action

service apache2 $action
service keystone $action

service glance-api $action
service glance-registry $action

service nova-api $action
service nova-cert $action
service nova-consoleauth $action
service nova-scheduler $action
service nova-conductor $action
service nova-novncproxy $action
service nova-compute $action

service neutron-server $action
service openvswitch-switch $action
service neutron-linuxbridge-agent $action
service neutron-l3-agent $action
service neutron-dhcp-agent $action
service neutron-metadata-agent $action
