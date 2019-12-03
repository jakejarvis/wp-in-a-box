#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

echo 'Installing MySQL / MariaDB Server'

sql_server=mysql-server

# https://dev.mysql.com/doc/mysql-apt-repo-quick-guide/en/
apt-key adv --keyserver pgp.mit.edu --recv-keys 5072E1F5

distro=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
codename=`lsb_release -c -s`
echo "deb http://repo.mysql.com/apt/$distro/ $codename mysql-8.0" > /etc/apt/sources.list.d/mysql.list
apt-get update

apt-get install ${sql_server} -qq &> /dev/null

systemctl stop mysql
# enable slow log and other tweaks
cp $local_wp_in_a_box_repo/config/mariadb.conf.d/*.cnf /etc/mysql/mariadb.conf.d/
systemctl start mysql

source /root/.envrc

echo 'Setting up MySQL user...'

if [ "$MYSQL_ADMIN_USER" == "" ]; then
    # create MYSQL username automatically
    MYSQL_ADMIN_USER="sqladmin_$(pwgen -A 8 1)"
    MYSQL_ADMIN_PASS=$(pwgen -cnsv 20 1)
    echo "export MYSQL_ADMIN_USER=$MYSQL_ADMIN_USER" >> /root/.envrc
    echo "export MYSQL_ADMIN_PASS=$MYSQL_ADMIN_PASS" >> /root/.envrc
    mysql -e "CREATE USER ${MYSQL_ADMIN_USER}@localhost IDENTIFIED BY '${MYSQL_ADMIN_PASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO ${MYSQL_ADMIN_USER}@localhost WITH GRANT OPTION"
fi
echo ... done setting up MySQL user.

echo ... done installing MySQL / MariaDB server!
