#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

sudo echo "[nginx-stable]" > /tmp/nginx.repo
sudo echo "name=nginx stable repo" >> /tmp/nginx.repo
sudo echo "baseurl=http://nginx.org/packages/centos/$releasever/$basearch/" >> /tmp/nginx.repo
sudo echo "gpgcheck=1" >>  /tmp/nginx.repo
sudo echo "enabled=1" >>  /tmp/nginx.repo   
sudo echo "gpgkey=https://nginx.org/keys/nginx_signing.key" >> /tmp/nginx.repo
sudo echo "module_hotfixes=true" >> /tmp/nginx.repo
sudo cp /tmp/nginx.repo  /etc/yum.repos.d/
sudo yum-config-manager --enable nginx-stable
# sudo yum update -y
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
sudo echo "<!DOCTYPE html>" > /tmp/index.html
sudo echo "<html>" >> /tmp/index.html
sudo echo "<body style=\"background-color:red;\">" >> /tmp/index.html
sudo echo "<h1>This is host my_hostname </h1>" >> /tmp/index.html
sudo echo "</body>" >> /tmp/index.html
sudo echo "</html>" >> /tmp/index.html
host_name=$(/usr/bin/hostname)
sed -i -e s/my_hostname/$host_name/g /tmp/index.html
sudo systemctl stop nginx
sleep 3
sudo rm -f /usr/share/nginx/html/index.html
sudo cp /tmp/index.html /usr/share/nginx/html/
sudo systemctl start nginx
