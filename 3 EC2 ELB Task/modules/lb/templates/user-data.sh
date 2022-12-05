#!/bin/sh
touch test1.txt
# yum update -y
touch test2.txt
amazon-linux-extras install -y nginx1
touch test3.txt
systemctl start nginx
touch test4.txt
systemctl enable nginx