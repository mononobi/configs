#!/bin/bash

echo "Configuring system."

service_file=/etc/systemd/system/hamdige.server.service
nginx_override_service_file=/etc/systemd/system/nginx.service.d/override.conf
system_config_file=/etc/systemd/system.conf
user_config_file=/etc/systemd/user.conf
security_config_file=/etc/security/limits.conf
sysctl_config_file=/etc/sysctl.conf

# removing current configs
if [ -f $sysctl_config_file ]
then
    rm $sysctl_config_file
fi

if [ -f $service_file ]
then
    rm $service_file
fi

if [ -f $system_config_file ]
then
    rm $system_config_file
fi

if [ -f $user_config_file ]
then
    rm $user_config_file
fi

if [ -f $security_config_file ]
then
    rm $security_config_file
fi

# setting new configs
cp ./configs/sysctl.conf $sysctl_config_file
sysctl -p

cp ./configs/limits.conf $security_config_file
cp ./configs/systemd/hamdige.server.service $service_file
cp ./configs/systemd/system.conf $system_config_file
cp ./configs/systemd/user.conf $user_config_file

# removing nginx configs.
nginx_file=/etc/nginx/sites-available/hamdige.server.nginx
nginx_symlink=/etc/nginx/sites-enabled/hamdige.server.nginx

if [ -f $nginx_file ]
then
    echo "Removing application nginx configs."
    rm $nginx_file
    rm $nginx_symlink
fi

echo "Configuring nginx service."
cp ./configs/nginx/hamdige.server.nginx $nginx_file
ln -s $nginx_file /etc/nginx/sites-enabled

if [ ! -d "/etc/systemd/system/nginx.service.d" ]
then
    mkdir -p /etc/systemd/system/nginx.service.d/
fi

if [ -f $nginx_override_service_file ]
then
   rm -r $nginx_override_service_file
fi

cp ./configs/nginx/override.conf $nginx_override_service_file

if [ -f "/etc/nginx/blocked-user-agents.rules" ]
then
    rm -r /etc/nginx/blocked-user-agents.rules
fi

cp ./configs/nginx/blocked-user-agents.rules /etc/nginx/blocked-user-agents.rules

nginx -t
