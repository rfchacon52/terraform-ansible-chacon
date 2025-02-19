#!/bin/bash
# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

sudo yum update -y
sudo yum install -y epel-release  # Install EPEL repository for additional packages
sudo yum install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx


sudo echo "<!DOCTYPE html>" > /tmp/index.html
sudo echo "<html> >> /tmp/index.html
sudo echo "<body style="background-color:red;">" >> /tmp/index.html
sudo echo "<h1>This is host my_hostname </h1>" >> /tmp/index.html
sudo echo "</body>" >> /tmp/index.html
sudo echo "</html>" >> /tmp/index.html

host_name=$(/usr/bin/hostname)
sed -i -e s/my_hostname/$host_name/g /tmp/index.html
sudo systemctl stop nginx
sudo cp /tmp/index.html /usr/share/testpage/index.html
sudo systemctl start nginx
