source userinput.sh
source admin-openrc

apt install openstack-dashboard -y
cp /etc/openstack-dashboard/local_settings.py /etc/openstack-dashboard/local_settings.$(date '+%m.%d.%Y.%H:%M:%S').py

sed -i '1i OPENSTACK_HOST = "controller"' /etc/openstack-dashboard/local_settings.py
sed -i "2i ALLOWED_HOSTS = ['*']" /etc/openstack-dashboard/local_settings.py
sed -i "3i SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

CACHES = {
    'default': {
         'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
         'LOCATION': 'controller:11211',
    }
}" /etc/openstack-dashboard/local_settings.py

sed -i '4i OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST' /etc/openstack-dashboard/local_settings.py
sed -i '5i OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True' /etc/openstack-dashboard/local_settings.py

sed -i '6i OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
}' /etc/openstack-dashboard/local_settings.py

sed -i '7i OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "default"' /etc/openstack-dashboard/local_settings.py
sed -i '8i OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"' /etc/openstack-dashboard/local_settings.py
sed -i '9i TIME_ZONE = "Asia/Kolkata"' /etc/openstack-dashboard/local_settings.py

apt-get remove --auto-remove openstack-dashboard-ubuntu-theme 
service apache2 reload
