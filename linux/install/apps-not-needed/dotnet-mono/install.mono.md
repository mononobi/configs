# Install Mono (.NET Framework)

## Add Repository

Depending on your Ubuntu version, add the Mono repository using the commands below:

### Ubuntu 20.04

```bash
sudo apt install gnupg ca-certificates
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-focal main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt update
```

### Ubuntu 18.04

```bash
sudo apt install gnupg ca-certificates
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
sudo apt update
```

## Installation (All Ubuntu Versions)

These packages let you build, compile, and run .NET and ASP.NET applications:

```bash
sudo apt install mono-devel
sudo apt install mono-complete
sudo apt install mono-dbg
sudo apt install referenceassemblies-pcl
sudo apt install mono-xsp4
```

### HTTPS Requests Support

If you run into trouble making HTTPS requests, install this package:

```bash
sudo apt install ca-certificates-mono
```
