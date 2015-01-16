#!/bin/bash -v
# Export the variable Env
source deployment.cfg

# Prepairing the Openstack Env
#sudo bash -c './pre_installation.sh'

echo "##### Install MYSQL #####"
sleep 3

sudo bash -c 'echo mysql-server mysql-server/root_password password $MYSQL_PASS | debconf-set-selections'
sudo bash -c 'echo mysql-server mysql-server/root_password_again password $MYSQL_PASS | debconf-set-selections'
sudo apt-get -y install mariadb-server python-mysqldb curl 

echo "##### Configuring MYSQL #####"
sleep 3


echo "########## CONFIGURING FOR MYSQL ##########"
sleep 5
sudo sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
#
sudo sed -i "/bind-address/a\default-storage-engine = innodb\n\
innodb_file_per_table\n\
collation-server = utf8_general_ci\n\
init-connect = 'SET NAMES utf8'\n\
character-set-server = utf8" /etc/mysql/my.cnf

#
sudo service mysql restart
sudo netstat -a | grep 3306
