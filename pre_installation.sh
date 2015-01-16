#!/bin/bash -exv
sudo apt-get update -y

# Import the variable Env
source deployment.cfg 

# Get host_name of server
host_name=`hostname`

# SETUP NTP ON THE OPENSTACK NODES
#------------------------------------------------------------------------------------------------
echo "Installing NTP Services"
sleep 3
sudo apt-get install ntp -y
sudo service ntp stop
sudo cp /etc/ntp.conf /etc/ntp.conf.bk
sudo sed -i 's/server/#server/' /etc/ntp.conf

if expr match "$host_name" "$ntp_server"; then
sudo sed -i 's/server ntp.ubuntu.com/ \
server 0.vn.pool.ntp.org iburst \
server 1.asia.pool.ntp.org iburst \
server 2.asia.pool.ntp.org iburst/g' /etc/ntp.conf

sudo sed -i 's/restrict -4 default kod notrap nomodify nopeer noquery/ \
#restrict -4 default kod notrap nomodify nopeer noquery/g' /etc/ntp.conf

sudo sed -i 's/restrict -6 default kod notrap nomodify nopeer noquery/ \
restrict -4 default kod notrap nomodify \
restrict -6 default kod notrap nomodify/g' /etc/ntp.conf
else
sudo sed -i 's/server/#server/' /etc/ntp.conf
sudo sed -i 's/#server ntp.ubuntu.com/ server ${ntp_server} iburst' /etc/ntp.conf
fi

sudo service ntp start
sudo ntpq -c peers
sleep 3
#----------------------------------------------------------------------------------------------------------

# Update Openstack Juno repos on Ubuntu 14.04
# Default is Openstack Icehouse
#----------------------------------------------------------------------------------------------------------
sudo apt-get install ubuntu-cloud-keyring -y
sudo touch /etc/apt/sources.list.d/cloudarchive-juno.list
sudo bash -c 'echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu" \
"trusty-updates/juno main" > /etc/apt/sources.list.d/cloudarchive-juno.list' 
sleep 3
echo "UPDATE PACKAGE FOR JUNO"
sudo apt-get -y update && sudo apt-get -y dist-upgrade
#----------------------------------------------------------------------------------------------------------
