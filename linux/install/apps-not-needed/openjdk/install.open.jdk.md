# Install OpenJDK 14

## Installation

Run the following commands to add the OpenJDK PPA and install OpenJDK 14:

```bash
sudo add-apt-repository ppa:openjdk-r/ppa
sudo apt-get update
sudo apt-get install openjdk-14-jdk
```

## Switching Java Versions

If you have more than one Java version installed on your system, use the following command to
switch versions:

```bash
sudo update-alternatives --config java
```

## Verification

Make sure your system is using the correct JDK by running:

```bash
java -version
```
