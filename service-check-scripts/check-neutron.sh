echo "Enter action[start|stop|status|restart]"
read -r action
action=$action
service neutron-server $action
service neutron-dhcp-agent $action
service neutron-l3-agent $action
service neutron-metadata-agent $action
service neutron-linuxbridge-agent $action
