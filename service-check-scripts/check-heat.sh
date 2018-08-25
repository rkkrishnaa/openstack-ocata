echo "Enter action[start|stop|status|restart]"
read -r action
action=$action
service heat-api $action
service heat-api-cfn $action
service heat-engine $action
