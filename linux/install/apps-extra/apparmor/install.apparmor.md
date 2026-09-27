# AppArmor Installation

To install AppArmor, run the following command:

```bash
sudo apt-get install apparmor
```

If your installation of AppArmor has issues working with other applications like Docker,
execute the following commands to reconfigure and restart it:

```bash
sudo dpkg-reconfigure apparmor
sudo /etc/init.d/apparmor restart
```

Now the problem should be fixed.
