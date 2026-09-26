# Install Python 3.13

Run the following commands to add the appropriate PPA and install Python 3.13 along with `pip` and its development headers:

```bash
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install python3.13
python3.13 --version
sudo apt-get install python3-pip
pip3 --version
sudo apt-get install python3.13-dev
sudo apt-get install python3.13-full
```
