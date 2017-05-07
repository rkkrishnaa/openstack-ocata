echo "Enter action[start|stop|status|restart]"
read -r action
action=$action
service nova-api $action
service nova-cert $action
service nova-consoleauth $action
service nova-scheduler $action
service nova-conductor $action
service nova-novncproxy $action
service nova-compute $action
