echo "Enter action[start|stop|status|restart]"
read -r action
action=$action
service mysql $action
service rabbitmq-server $action
service memcached $action
service chrony $action
