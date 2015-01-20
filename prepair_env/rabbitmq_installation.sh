#!/bin/bash -exv
source deployment.cfg

##############################################
echo "Install and Config RabbitMQ"
sleep 3
sudo apt-get install rabbitmq-server -y
sudo rabbitmqctl change_password guest $RABBIT_PASS
sleep 3

sudo service rabbitmq-server restart
echo "Finish setup pre-install package !!!"
