#!/bin/bash

apt-get remove --purge libreoffice* -y
apt-get clean -y
apt-get autoremove -y

apt-get remove --purge transmission* -y
apt-get clean -y
apt-get autoremove -y

apt-get remove --purge remmina* -y
apt-get clean -y
apt-get autoremove -y

apt-get remove --purge shotwell* -y
apt-get clean -y
apt-get autoremove -y
