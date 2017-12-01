#!/bin/bash
#run commands and fetch error if occurs
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

#install docker and docker-compose
sudo yum -y update
sudo yum -y install docker
sudo pip install docker-compose
sudo pip install backports.ssl_match_hostname --upgrade

#start docker service
sudo service docker start
sudo usermod -a -G docker ec2-user

#create markerfile
touch ec2-init-done.markerfile
