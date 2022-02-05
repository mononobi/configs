#!/bin/bash

# installing dependencies.
./install-dependencies.sh

full_installation="n"
# shellcheck disable=SC2039
read -r -p "Perform a full installation? [y/N] " full_installation

full_installation_length=${#full_installation}
if [ "$full_installation_length" = "0" ]
then
    full_installation="n"
fi

# getting working directory path.
working_dir=$(pwd)

# user name that application should be accessible to it.
user_name=app_user

# checking that user_name is present, if not, create it.
user_exists=$(id -u $user_name > /dev/null 2>&1; echo $?)

if [ "$user_exists" != "0" ]
then
    # user does not exist, creating it.
    echo "Creating $user_name."
    adduser $user_name
else
    echo "$user_name is already present."
fi

# adding user_name into www-data and sudo groups.
usermod -aG sudo $user_name
usermod -aG www-data $user_name

service_file=/etc/systemd/system/hamdige.server.service

# stopping current application service.
if [ "$full_installation" = "Y" ] || [ "$full_installation" = "y" ]
then
    if [ -f $service_file ]
    then
        echo "Stopping current application service."
        systemctl stop hamdige.server.service
        systemctl disable hamdige.server.service
    fi

    # making logging directory and log backup.
    if [ ! -d "/var/log/backup/hamdige" ]
    then
        mkdir -p /var/log/backup/hamdige/
    fi

    if [ -d "/var/log/hamdige" ]
    then
        echo "Archiving and cleaning up previous logs."
        name=$(date "+%Y.%m.%d.%H.%M.%S")
        tar -czf /var/log/backup/hamdige/"hamdige.log.$name.tar.gz" /var/log/hamdige
        rm -r /var/log/hamdige
    fi

    mkdir -p /var/log/hamdige/nginx

    # setting permissions for log directory.
    chown -R $user_name:www-data /var/log/hamdige/
    chmod -R 770 /var/log/hamdige/
fi

# making application backup directory and file.
if [ ! -d "/var/app_root/backup/hamdige_server" ]
then
    mkdir -p /var/app_root/backup/hamdige_server/
fi

if [ -d "/var/app_root/hamdige_server" ]
then
    echo "Archiving and cleaning up previous installation."
    name=$(date "+%Y.%m.%d.%H.%M.%S")
    tar -czf /var/app_root/backup/hamdige_server/"hamdige_server.$name.tar.gz" /var/app_root/hamdige_server

    if [ "$full_installation" = "Y" ] || [ "$full_installation" = "y" ]
    then
        rm -r /var/app_root/hamdige_server
    else
        rm -r /var/app_root/hamdige_server/app/
    fi
else
    if [ "$full_installation" = "Y" ] || [ "$full_installation" = "y" ]
    then
        mkdir -p /var/app_root/backup/hamdige_server/
        echo "Performing fresh installation."
    else
        echo "Previous installation is incomplete, a full installation must be performed first."
        exit 1
    fi
fi

# making up required directory.
mkdir -p /var/app_root/hamdige_server/app/

echo "Copying applications."

# copying hamdige application.
cp -r ../../src/hamdige/ /var/app_root/hamdige_server/app/hamdige/
cp ../../src/start.py /var/app_root/hamdige_server/app/start.py
cp ../../src/wsgi.py /var/app_root/hamdige_server/app/wsgi.py

# copying resources.
cp -r ../../resources/ /var/app_root/hamdige_server/resources/

# copying .env file.
cp ../../src/.env /var/app_root/hamdige_server/app/.env

# copying pipenv required files.
cp ../../Pipfile.lock /var/app_root/hamdige_server/Pipfile.lock
cp ../../Pipfile /var/app_root/hamdige_server/Pipfile

if [ "$full_installation" = "Y" ] || [ "$full_installation" = "y" ]
then
    # creating pipenv environment.
    cd /var/app_root/hamdige_server/ || exit 1
    export PIPENV_VENV_IN_PROJECT=1
    pipenv install --ignore-pipfile

    #returning to working directory.
    cd "$working_dir" || exit 1
else
    # updating dependencies from Pipfile.lock.
    cd /var/app_root/hamdige_server/ || exit 1
    pipenv sync

    #returning to working directory.
    cd "$working_dir" || exit 1
fi

# setting the owner of directory.
chown -R $user_name /var/app_root/

if [ "$full_installation" = "Y" ] || [ "$full_installation" = "y" ]
then
    # configuring system.
    ./configure-system.sh

    # reloading configs
    systemctl daemon-reload

    echo "Starting application service."
    systemctl start hamdige.server.service
    systemctl enable hamdige.server.service

    echo "Starting nginx service."
    systemctl start nginx
    systemctl reload nginx
    ufw allow 'Nginx Full'
    ufw enable
else
    echo "Reloading application service."
    systemctl daemon-reload
    systemctl reload hamdige.server.service
fi

echo
(sleep 5; echo -e "\e[0;32m** Installation completed **\e[0m")
echo

systemctl status hamdige.server.service
