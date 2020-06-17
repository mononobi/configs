#!/bin/bash

force_update="n"
# shellcheck disable=SC2039
read -r -p "Force update all installed dependencies? [y/N] " force_update

force_update_length=${#force_update}
if [ "$force_update_length" = "0" ]
then
    force_update="n"
fi

# installing gcc.
gcc_path=$(command -v gcc)
gcc_length=${#gcc_path}

if [ "$gcc_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing gcc."
    apt-get install gcc
else
    echo "gcc is already installed."
fi

# installing g++.
gpp_path=$(command -v g++)
gpp_length=${#gpp_path}

if [ "$gpp_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing g++."
    apt-get install g++
else
    echo "g++ is already installed."
fi

# installing git.
git_path=$(command -v git)
git_length=${#git_path}

if [ "$git_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing git."
    apt-get install git
else
    echo "git is already installed."
fi

# installing netstat.
netstat_path=$(command -v netstat)
netstat_length=${#netstat_path}

if [ "$netstat_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing netstat."
    apt-get install net-tools
else
    echo "netstat is already installed."
fi

# installing curl.
curl_path=$(command -v curl)
curl_length=${#curl_path}

if [ "$curl_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing curl."
    apt-get install curl
else
    echo "curl is already installed."
fi

# installing syslog.
syslog_path=$(command -v syslog-ng)
syslog_length=${#syslog_path}

if [ "$syslog_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing syslog."
    apt-get install syslog-ng-core
else
    echo "syslog is already installed."
fi

# installing ufw.
ufw_path=$(command -v ufw)
ufw_length=${#ufw_path}

if [ "$ufw_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing ufw."
    apt-get install ufw
else
    echo "ufw is already installed."
fi

# installing nginx.
nginx_path=$(command -v nginx)
nginx_length=${#nginx_path}

if [ "$nginx_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing nginx."
    apt-get install nginx
else
    echo "nginx is already installed."
fi

# installing python2.7
python27_path=$(command -v python2.7)
python27_length=${#python27_path}

if [ "$python27_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing python2.7"
    apt-get install python2.7
else
    echo "python2.7 is already installed."
fi

# installing pip.
pip_path=$(command -v pip)
pip_length=${#pip_path}

if [ "$pip_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing pip."
    apt-get install python-pip
else
    echo "pip is already installed."
fi

# installing python3.7
python37_path=$(command -v python3.7)
python37_length=${#python37_path}

if [ "$python37_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing python3.7"
    apt update
    apt install software-properties-common
    add-apt-repository ppa:deadsnakes/ppa
    apt install python3.7
else
    echo "python3.7 is already installed."
fi

# installing pip3
pip3_path=$(command -v pip3)
pip3_length=${#pip3_path}

if [ "$pip3_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing pip3"
    apt update
    apt install software-properties-common
    add-apt-repository ppa:deadsnakes/ppa
    apt-get install python3-pip
else
    echo "pip3 is already installed."
fi

# installing uwsgi.
uwsgi_path=$(command -v uwsgi)
uwsgi_length=${#uwsgi_path}

if [ "$uwsgi_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing uwsgi."
    apt-get install uwsgi
else
    echo "uwsgi is already installed."
fi

# installing uwsgi's python3.7 plugin.
if [ ! -f "/usr/lib/uwsgi/plugins/python37_plugin.so" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing uwsgi's python3.7 plugin."
    apt install python3.7 python3.7-dev python3-distutils uwsgi uwsgi-src uuid-dev libcap-dev libpcre3-dev libssl-dev zlib1g-dev
    export PYTHON=python3.7
    uwsgi --build-plugin "/usr/src/uwsgi/plugins/python python37"
    mv python37_plugin.so /usr/lib/uwsgi/plugins/python37_plugin.so
    chmod 644 /usr/lib/uwsgi/plugins/python37_plugin.so
else
    echo "uwsgi's python3.7 plugin is already installed."
fi

# installing odbcinst.
odbcinst_path=$(command -v odbcinst)
odbcinst_length=${#odbcinst_path}

if [ "$odbcinst_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing odbcinst."
    curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
    apt-get update
    ACCEPT_EULA=Y apt-get install msodbcsql17
    ACCEPT_EULA=Y apt-get install mssql-tools
    # shellcheck disable=SC2016
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
    # shellcheck disable=SC2016
    echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
    # shellcheck disable=SC1090
    . ~/.bashrc
    apt-get install unixodbc-dev
    odbcinst -j
else
    echo "odbcinst is already installed."
fi

# installing pipenv.
pipenv_path=$(command -v pipenv)
pipenv_length=${#pipenv_path}

if [ "$pipenv_length" = "0" ] || [ $force_update = "Y" ] || [ $force_update = "y" ]
then
    echo "Installing pipenv."
    pip install pipenv
else
    echo "pipenv is already installed."
fi
