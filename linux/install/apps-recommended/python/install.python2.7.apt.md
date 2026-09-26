# Python 2.7 Installation via APT

To install Python 2.7, run the following command:

```bash
sudo apt-get install python2.7
```

## Installing `pip` for Python 2.7

### Ubuntu 18.04

```bash
sudo apt install python-pip
```

### Ubuntu 20.04

```bash
sudo add-apt-repository universe
sudo apt update
curl https://bootstrap.pypa.io/get-pip.py --output get-pip.py
sudo python2.7 get-pip.py
```
