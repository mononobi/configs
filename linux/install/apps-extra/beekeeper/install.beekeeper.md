# Beekeeper Studio Installation

Beekeeper Studio is an open-source, cross-platform database management tool. It functions similarly to pgAdmin but offers a relatively better UI and supports all major databases. However, it has significantly fewer features than DBeaver.

For more information, see the [official installation documentation](https://docs.beekeeperstudio.io/installation).

To install Beekeeper Studio, run the following commands:

```bash
wget --quiet -O - https://deb.beekeeperstudio.io/beekeeper.key | sudo apt-key add -
echo "deb https://deb.beekeeperstudio.io stable main" | sudo tee /etc/apt/sources.list.d/beekeeper-studio-app.list
sudo apt update
sudo apt install beekeeper-studio
```
