echo "Enter action[start|stop|status|restart]"
read -r action
action=$action
service glance-registry $action
service glance-api $action
