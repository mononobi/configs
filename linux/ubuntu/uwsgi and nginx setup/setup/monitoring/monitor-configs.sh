#!/bin/bash

# shows the number of in use and unused open file descriptors
# and max open file descriptors system-wide limit.
echo -e "\e[0;32mFile descriptors information:\e[0m"
echo "In use - Unused - Max system-wide limit"
cat /proc/sys/fs/file-nr

# shows the max open file descriptors system-wide limit.
echo -e "\e[0;32mMax open file descriptors system-wide limit:\e[0m"
sysctl fs.file-max

# shows the max number of file descriptors system-wide limit for a single process.
echo -e "\e[0;32mMax number of file descriptors system-wide limit for a single process:\e[0m"
sysctl fs.nr_open

# shows all systemd configs set in system.conf.
echo -e "\e[0;32msystemd system.conf configs:\e[0m"
cat /etc/systemd/system.conf

# shows all systemd configs set in user.conf.
echo -e "\e[0;32msystemd user.conf configs:\e[0m"
cat /etc/systemd/user.conf

# shows all limits set in limits.conf per user.
echo -e "\e[0;32mFull limits.conf details per user:\e[0m"
cat /etc/security/limits.conf

# shows all configs set in sysctl.conf.
echo -e "\e[0;32msysctl.conf configs:\e[0m"
cat /etc/sysctl.conf
