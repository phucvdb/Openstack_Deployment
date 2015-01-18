#!/bin/bash -v
# Export the variable Env
source deployment.cfg

echo "##### Install MYSQL #####"
sleep 3

sudo bash -c 'sudo echo mysql-server mysql-server/root_password password $MYSQL_PASS | sudo debconf-set-selections'
sudo bash -c 'sudo echo mysql-server mysql-server/root_password_again password $MYSQL_PASS | sudo debconf-set-selections'
sudo dpkg --configure -a
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
sudo netstat -a | grep mysql

# Make sure that NOBODY can access the server without a password
sudo mysql -e "UPDATE mysql.user SET Password = PASSWORD('$MYSQL_PASS') WHERE User = 'root'"
# Kill the anonymous users
sudo mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
sudo mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
sudo mysql -e "DROP DATABASE test"
# Make our changes take effect
sudo mysql -e "FLUSH PRIVILEGES"
# Any subsequent tries to run queries this way will get access denied because lack of usr/pwd param
