#Openstack Ocata bash script installation
#This shell script upgrades sofware packages to the latest version.
#Mysql server, Rabbit MQ server and Memcached server will be installed after software upgrade.

source userinput.sh
source admin-openrc
export ip=$(/sbin/ifconfig $PUBLIC_INTERFACE_NAME | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')
echo "$ip controller" >> /etc/hosts

#software update and upgrade
apt update 
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy upgrade
DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confnew" --force-yes -fuy dist-upgrade
apt install software-properties-common -y
add-apt-repository cloud-archive:ocata -y
apt update && apt dist-upgrade -y
apt install python-openstackclient crudini -y

#install mysql server
apt install mariadb-server python-pymysql -y
echo mariadb-server-5.5 mysql-server/root_password password ${DBPASS} | debconf-set-selections
echo mariadb-server-5.5 mysql-server/root_password_again password ${DBPASS} | debconf-set-selections
touch /etc/mysql/mariadb.conf.d/99-openstack.cnf
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld bind-address 0.0.0.0
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld default-storage-engine innodb
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld innodb_file_per_table on
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld max_connections 4096
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld collation-server utf8_general_ci
crudini --set /etc/mysql/mariadb.conf.d/99-openstack.cnf mysqld character-set-server utf8
service mysql restart

#install rabbit mq server
apt install rabbitmq-server -y 
rabbitmqctl add_user openstack $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

#install memcached server
apt install memcached python-memcache -y 
sed -i 's/.*127.0.0.1*/-l '$ip'/g' /etc/memcached.conf
service memcached restart

#install ntp server
apt install chrony -y
cp /etc/chrony/chrony.conf /etc/chrony/chrony.$(date '+%m.%d.%Y.%H:%M:%S').conf
sudo sed -i "20i server $NTP_SERVER_CONTROLLER_NODE iburst" /etc/chrony/chrony.conf
sudo sed -i '/debian.pool.ntp.org/d' /etc/chrony/chrony.conf
service chrony restart
