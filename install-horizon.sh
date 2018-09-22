source userinput.sh
source admin-openrc

apt install openstack-dashboard -y
cp /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.$(date '+%m.%d.%Y.%H:%M:%S').py

sed -i '12i OPENSTACK_HOST = "controller"' /etc/openstack-dashboard/local_settings.py
sed -i "13i ALLOWED_HOSTS = ['*']" /etc/openstack-dashboard/local_settings.py
sed -i "14i SESSION_ENGINE = 'django.contrib.sessions.backends.cache'" /etc/openstack-dashboard/local_settings.py
sed -i "15i CACHES = { 'default': { 'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache', 'LOCATION': 'controller:11211', } }" /etc/openstack-dashboard/local_settings.py
sed -i '16i OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST' /etc/openstack-dashboard/local_settings.py
sed -i '17i OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True' /etc/openstack-dashboard/local_settings.py
sed -i '18i OPENSTACK_API_VERSIONS = { "identity": 3, "image": 2, "volume": 2, }' /etc/openstack-dashboard/local_settings.py
sed -i '19i OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"' /etc/openstack-dashboard/local_settings.py
sed -i '20i OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"' /etc/openstack-dashboard/local_settings.py
sed -i '21i TIME_ZONE = "Asia/Kolkata"' /etc/openstack-dashboard/local_settings.py
cp local_settings.py /etc/openstack-dashboard/local_settings.py
apt-get remove --auto-remove openstack-dashboard-ubuntu-theme -y
rm -rf /var/lib/openstack-dashboard/secret_key
service apache2 restart
