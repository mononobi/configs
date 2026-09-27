# Install Python 3.14 via APT

This guide outlines the steps to install Python 3.14 on Ubuntu using the deadsnakes PPA.

## Installation Steps

Run the following commands sequentially to set up the PPA and install Python 3.14 along
with its associated tools:

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.14
python3.14 --version
sudo apt-get install python3-pip
pip3 --version
sudo apt-get install python3.14-dev
sudo apt-get install python3.14-full
```
