source userinput.sh
source admin-openrc

apt install openstack-dashboard -y
cp /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.$(date '+%m.%d.%Y.%H:%M:%S').py
cp local_settings.py /etc/openstack-dashboard/local_settings.py
apt-get remove --auto-remove openstack-dashboard-ubuntu-theme -y
rm -rf /var/lib/openstack-dashboard/secret_key
service apache2 restart
