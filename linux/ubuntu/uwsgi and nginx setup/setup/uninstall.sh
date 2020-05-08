#!/bin/bash

remove="n"
# shellcheck disable=SC2039
read -r -p "Uninstall 'hamdige_server' application? [y/N] " remove

service_file=/etc/systemd/system/hamdige.server.service
nginx_file=/etc/nginx/sites-available/hamdige.server.nginx
nginx_symlink=/etc/nginx/sites-enabled/hamdige.server.nginx

if [ "$remove" = "Y" ] || [ "$remove" = "y" ]
then
    if [ -f $service_file ]
    then
        echo "Stopping current application service."
        systemctl stop hamdige.server.service
        systemctl disable hamdige.server.service
        rm -r $service_file
    fi

    if [ -d "/var/log/hamdige" ]
    then
        rm -r /var/log/hamdige/*
    fi

    if [ -d "/var/app_root/hamdige_server" ]
    then
        rm -r /var/app_root/hamdige_server/
    fi

    if [ -f $nginx_file ]
    then
        echo "Removing application nginx configs."
        rm $nginx_file
        rm $nginx_symlink

        systemctl daemon-reload
        systemctl start nginx
        systemctl reload nginx
    fi

    echo
    echo -e "\e[0;32m** Uninstallation completed **\e[0m"
    echo
fi
