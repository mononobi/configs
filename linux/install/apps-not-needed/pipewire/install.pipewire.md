# PipeWire

> **Note:** From Ubuntu 24.04, PipeWire is in use by default and there is no need for
> this.

> **WARNING:** INSTALL PIPEWIRE AT YOUR OWN RISK. IT DOES NOT WORK CORRECTLY AFTER A FEW
> UPDATES. IT WILL ALSO REMOVE YOUR GNOME DESKTOP IF YOU UNINSTALL IT.

PipeWire is an audio server which has better quality than PulseAudio, which is the default
on Ubuntu and most other distros.

`wireplumber` is the recommended library over `pipewire-media-session`. Note that only one
of `wireplumber` or `pipewire-media-session` should be installed.

To enable PipeWire and disable PulseAudio, execute these commands. Note that you should
not execute all commands with `sudo`, only some of them:

```bash
sudo add-apt-repository ppa:pipewire-debian/pipewire-upstream
```

Execute the below line if you want `wireplumber`:

```bash
sudo add-apt-repository ppa:pipewire-debian/wireplumber-upstream
```

```bash
sudo apt update
sudo apt install libfdk-aac2 libldacbt-{abr,enc}2 libopenaptx0
sudo apt install gstreamer1.0-pipewire libpipewire-0.3-{0,dev,modules} libspa-0.2-{bluetooth,dev,jack,modules} pipewire{,-{audio-client-libraries,pulse,bin,locales,tests,doc}}
```

Execute the below line if you want `pipewire-media-session`:

```bash
sudo apt-get install pipewire-media-session
```

Execute the below line if you want `wireplumber`:

```bash
sudo apt-get install wireplumber{,-doc} gir1.2-wp-0.4 libwireplumber-0.4-{0,dev}
```

```bash
sudo apt-get remove --purge blueman && sudo rm -f /var/lib/blueman/network.state
sudo apt-get install blueman-git

systemctl --user daemon-reload
systemctl --user --now disable pulseaudio.{socket,service}
systemctl --user mask pulseaudio
systemctl --user --now enable pipewire{,-pulse}.{socket,service}
```

Execute the below line if you want `pipewire-media-session`:

```bash
systemctl --user --now enable pipewire-media-session.service
```

Execute the below line if you want `wireplumber`:

```bash
systemctl --user --now enable wireplumber.service
```

```bash
sudo systemctl enable --now blueman-mechanism.service
```

Now execute this to check if PipeWire is enabled:

```bash
pactl info
```

## To Disable Pipewire and Revert to PulseAudio

Execute these commands:

```bash
sudo apt remove --purge pipewire
sudo apt remove gstreamer1.0-pipewire libpipewire-0.3-{0,dev,modules} libspa-0.2-{bluetooth,dev,jack,modules} pipewire{,-{audio-client-libraries,pulse,bin,locales,tests,doc}}
```

Execute the below line if you have installed `pipewire-media-session`:

```bash
sudo apt remove pipewire-media-session
```

Execute the below line if you have installed `wireplumber`:

```bash
sudo apt remove wireplumber{,-doc} gir1.2-wp-0.4 libwireplumber-0.4-{0,dev}
```

Delete all files starting with `pipewire` from this folder: `/etc/apt/sources.list.d/`

Go to this folder and remove all files and folders starting with `pipewire`:

```bash
cd ~/.config/systemd/user
```

Execute these commands:

```bash
sudo rm -r /usr/share/pipewire/

systemctl --user unmask pulseaudio
systemctl --user daemon-reload
systemctl --user --now enable pulseaudio.service pulseaudio.socket
```

If you did execute the above commands and GUI got disappeared, execute the remaining
commands from CLI and then execute this:

```bash
sudo apt-get install --reinstall ubuntu-desktop
```

Reboot the system and then execute these commands:

```bash
sudo apt-get install --reinstall alsa-base pulseaudio
sudo alsa force-reload
```

Reboot again and then execute this:

```bash
pulseaudio --start
```

Now execute this to check if PulseAudio is enabled:

```bash
pactl info
```
