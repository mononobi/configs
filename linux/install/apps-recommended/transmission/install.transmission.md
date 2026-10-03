# Transmission Installation Guide

To install the default Transmission client:

```bash
sudo apt-get install transmission
```

## Latest Client (Ubuntu <= 20.10)

To install the latest client on Ubuntu 20.10 or older:

```bash
sudo add-apt-repository ppa:transmissionbt/ppa
sudo apt-get update
sudo apt-get install transmission-gtk transmission-common
```

## Latest Client with Remote and CLI Access (Ubuntu <= 20.10)

To install the latest client along with remote and command-line access tools on Ubuntu 20.10 or
older:

```bash
sudo add-apt-repository ppa:transmissionbt/ppa
sudo apt-get update
sudo apt-get install transmission-gtk transmission-cli transmission-common transmission-daemon
```
