#!/bin/bash

# this configuration script must be executed on a raw server for the
# first time only, reboot is required for changes to take effect.

# installing dependencies.
./install-dependencies.sh

# configuring nf_conntrack.
nf_conntrack_file=/etc/modprobe.d/nf_conntrack.conf

if [ ! -d "/etc/modprobe.d" ]
then
    mkdir -p /etc/modprobe.d/
fi

if [ -f $nf_conntrack_file ]
then
    rm $nf_conntrack_file
fi

cp ./configs/nf_conntrack.conf $nf_conntrack_file

echo "Configuring nf_conntrack."
systemctl stop ufw
modprobe -rv nf_conntrack
systemctl start ufw

echo "System must be rebooted for changes to take effect."
# shellcheck disable=SC2039
read -r -p "Reboot system now? [y/N] " reboot

reboot_length=${#reboot}
if [ "$reboot_length" = "0" ]
then
    reboot="n"
fi

if [ "$reboot" = "Y" ]  || [ "$reboot" = "y" ]
then
    echo "System is rebooting."
    reboot
fi
