#!/bin/bash
yum install -y httpd
cd /var/www/html
wget ${index}
wget ${image}
service httpd start
