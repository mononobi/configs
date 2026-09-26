# Install Python 3.7 (APT)

This document provides the commands to install Python 3.7 and its development packages.

## Installation Commands

Run the following commands to add the repository and install Python 3.7 along with `pip` and development headers:

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.7
python3.7 --version
sudo apt-get install python3-pip
pip3 --version
sudo apt-get install python3.7-dev
sudo apt-get install python3.7-full
```
