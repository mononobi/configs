# Wireshark

> **Note:** Wireshark is a network protocol and packet analyzer.

## Installation

Run the following command to install Wireshark:

```bash
sudo apt-get install wireshark
```

## Post-Installation Setup

Execute the following command after installation to be able to inspect the network from the GUI without root access:

```bash
sudo dpkg-reconfigure wireshark-common
```

When prompted, select **'Yes'** as your response. Then, execute this command:

```bash
sudo usermod -a -G wireshark USER_NAME
```

> **Warning:** You need to restart the PC for this change to take effect.
