# Python 3.11 Installation (APT)

Follow these steps to install Python 3.11, pip, and additional development packages using the
`deadsnakes` PPA.

## 1. Add Repository and Install Python 3.11

Update your package lists, add the `deadsnakes` PPA, and install Python 3.11:

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.11
python3.11 --version
```

## 2. Install pip

Install the package installer for Python (`pip`):

```bash
sudo apt-get install python3-pip
pip3 --version
```

## 3. Install Additional Packages

Install the Python 3.11 development and full packages:

```bash
sudo apt-get install python3.11-dev
sudo apt-get install python3.11-full
```
