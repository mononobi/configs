# Virt-Manager Installation and Configuration Guide

To install `virt-manager`, run the following command:

```bash
sudo apt-get install virt-manager
```

After installation, execute this command to see if your CPU supports KVM:

```bash
kvm-ok
```

Alternatively, you can execute this command. If it returns a value greater than 0, your
CPU supports KVM:

```bash
egrep -c '(vmx|svm)' /proc/cpuinfo
```

If your CPU supports KVM, install these packages:

```bash
sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
```

After installation, execute the following commands to be able to create and run virtual
machines without root access:

```bash
sudo usermod -aG libvirt USER_NAME
sudo usermod -aG kvm USER_NAME
```

> **Note:** You need to restart the PC for this change to take effect.

---

## Configs to Use the Correct Resolution on Any Guest

### Display

- **Type:** Spice server
- **Listen type:** None
- **OpenGL:** Enabled

### Video

- **Model:** Virtio
- **3D Acceleration:** Enabled

### Note

In the main virt-manager window for your running VM, go to the **"View"** menu -> **"Scale
Display"** and check these two options:

- "Always"
- "Auto resize VM with window"

### Dependency

On Non-Ubuntu Linux guests, you need to install these packages:

```bash
sudo apt update
sudo apt install spice-vdagent qemu-guest-agent
```

---

## Configs for Installing Windows 11 Guest

### Installation Configs

#### Hypervisor

- **Chipset:** Q35
- **Firmware:** UEFI x86_64: `/usr/share/OVMF/OVMF_CODE_4M.secboot.fd`

#### Display

- **Type:** Spice server
- **Listen type:** Address (or empty)
- **Port:** Auto

#### Video

- **Model:** QXL

#### TPM

- **Type:** Emulated
- **Model:** TIS
- **Version:** 2.0

#### Disk 1

Edit the disk 1 storage which will be used to install Windows on and set this:

- **Bus Type:** VirtIO

#### NIC (Network)

- **Device model:** virtio

#### CD-ROM 2

Add a new hardware device for a second CD-ROM:

- **Device Type:** CD-ROM device
- **Bus Type:** SATA
- **Readonly:** True
- **Select or create custom storage:** Select the virtio libs `.iso` file.

> **Note:** It is required to install dependencies during the setup and also after booting
> into Windows. You can download the ISO here:
> [virtio-win.iso](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso)

#### Recommended Resources for the Win 11 VM

- **CPU:** 8
- **RAM:** 10240 MB

### Installation

When you reach the "Where do you want to install Windows?" screen, you will likely see a
blank list with the message "We couldn't find any drives." This is normal because Windows
doesn't have built-in VirtIO storage drivers.

1. Click **"Load driver"** at the bottom left.
2. In the "Load Driver" dialog, click **"Browse"**.
3. Navigate to the virtio-win CD-ROM drive (CD-ROM 2).
4. Select the following folder for the storage driver: `viostor -> w11 -> amd64`.
5. Click **"OK"**. The setup will find the "Red Hat VirtIO SCSI pass-through controller"
   driver.
6. Click **"Next"** to install the driver. After a moment, your virtual disk will appear
   in the list (DISK 1).
7. Select the unallocated space on the disk and click **"Next"** to begin the
   installation.

### Post Installation

Once Windows 11 is installed and you've booted to the desktop:

**Install Guest Tools:** Open File Explorer, navigate to the `virtio-win` CD-ROM, and run
these 3 installers:

- `CD-ROM:/virtio-win-guest-tools.exe`
- `CD-ROM:/guest-agent/qemu-ga-x86_64.msi`
- `CD-ROM:/virtio-win-gt-x64.msi`

**Change Configs:** After the guest tools are installed, you can shut down the VM. Go into
its hardware settings in virt-manager and change the following settings:

#### Post Installation Configs

##### Display

- **Type:** Spice server
- **Listen type:** None
- **OpenGL:** Enabled

##### Video

- **Model:** Virtio
- **3D Acceleration:** Enabled

##### Note

In the main virt-manager window for your running VM, go to the **"View"** menu -> **"Scale
Display"** and check these two options:

- "Always"
- "Auto resize VM with window"

> **Note:** Even after applying these, you'll still need to manually select the correct
> resolution every time you boot into Windows, but without this, you won't even see the
> correct resolution to select.

#### Remove These Hardware When Done

- CD-ROM 1
- CD-ROM 2
