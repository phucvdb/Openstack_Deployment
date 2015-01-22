#!/bin/bash -v
# Generate a random value to use as the administration token during initial configuration
SET_TOKEN_PASS="TOKEN_PASS=" + `openssl rand -hex 10`
sed -i 's/TOKEN_PASS=/$SET_TOKEN_PASS/g' ../deployment.cfg

source ../deployment.cfg

echo "###### Install Keystone Service ######"
sleep 3

sudo apt-get install keystone python-keystoneclient -y

# Config Keystone Serivce
KT_DBconnect="connection = mysql://keystone:$KEYSTONE_DBPASS@$DB_HOST/keystone"
sudo service keystone stop
sleep 3
sudo cp /etc/keystone/keystone.conf /etc/keystone/keystone.conf.bk
sudo sed -i 's/#admin_token = ADMIN/admin_token = ${TOKEN_PASS}/g' /etc/keystone/keystone.conf
sudo sed -i 's/#connection = <None>/${KT_DBconnect}/g' /etc/keystone/keystone.conf
sudo sed -i 's/#connection = <None>/${KT_DBconnect}/g' /etc/keystone/keystone.conf
sudo sed -i 's/#provider = <None>/provider = keystone.token.providers.uuid.Provider/g' /etc/keystone/keystone.conf
sudo sed -i 's/#driver = keystone.token.persistence.backends.sql.Token/driver = keystone.token.persistence.backends.sql.Token/g' /etc/keystone/keystone.conf
sudo sed -i 's/#verbose = false/verbose = True/g' /etc/keystone/keystone.conf

echo "##### Remove keystone default db #####"
sudo rm -f /var/lib/keystone/keystone.db

echo "##### Syncing keystone DB #####"
sudo service keystone start
sudo su -s /bin/sh -c "keystone-manage db_sync" keystone

echo "##### Restarting keystone service #####"
sudo service keystone restart

# configure a periodic task that purges expired tokens hourly
(sudo crontab -l -u keystone 2>&1 | grep -q token_flush) || \
sudo echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/crontabs/keystone
