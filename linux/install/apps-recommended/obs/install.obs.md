# OBS Studio

OBS (Open Broadcaster Software) is a powerful, open-source tool for screen recording and
live streaming.

## Installation

### Core Installation

To install OBS Studio, you will need to add the official PPA and then install the package:

```bash
sudo add-apt-repository ppa:obsproject/obs-studio
sudo apt update
sudo apt install obs-studio
```

### Optional Dependencies

**Multiverse Repository**  
Enable the multiverse repository to access proprietary media codecs and hardware encoders
(e.g., NVENC).

> Note: Most desktop Ubuntu versions have this enabled by default.

```bash
sudo add-apt-repository multiverse
```

**Advanced FFmpeg Features**  
Install the full FFmpeg toolkit if you plan to use Advanced Custom FFmpeg outputs.

> Note: Basic OBS usage automatically pulls in the necessary background libraries.

```bash
sudo apt install ffmpeg
```

**Virtual Camera Support**  
Install this package if you specifically need the "Start Virtual Camera" feature.

> **WARNING**: `v4l2loopback-dkms` is known to occasionally cause kernel panics! Only
> install this if you specifically need the "Start Virtual Camera" feature.

```bash
sudo apt install v4l2loopback-dkms
```

## Troubleshooting

OBS requires OpenGL 3.3 or higher (GPU Hardware Acceleration). OpenGL 3.3 is from 2010, so
virtually all modern computers natively have it!

> Note: You cannot `apt install opengl`. It is provided by your GPU drivers.
>
> - **NVIDIA**: Install proprietary drivers (e.g., `sudo ubuntu-drivers autoinstall`)
> - **Virtual Machines**: Enable "3D Acceleration" in your VM display settings.

To check your current OpenGL version, install `mesa-utils`:

```bash
sudo apt install mesa-utils
```

Then execute this command:

```bash
glxinfo | grep "OpenGL"
```

If your system has OpenGL >= 3.3, OBS will launch successfully.
