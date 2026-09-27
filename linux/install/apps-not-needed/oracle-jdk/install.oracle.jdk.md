# Oracle JDK Installation Guide

Follow these steps to manually install the Oracle JDK:

1. Remove any existing OpenJDK installations:

   ```bash
   sudo apt-get purge openjdk-\*
   ```

2. Create a directory for the Java installation:

   ```bash
   sudo mkdir -p /usr/local/java
   ```

3. Copy the downloaded JDK tarball to the new directory:

   ```bash
   sudo cp -r jdk-8u51-linux-x64.tar.gz /usr/local/java/
   ```

4. Extract the archive:

   ```bash
   sudo tar xvzf jdk-8u51-linux-x64.tar.gz
   ```

5. Update your system PATH. Open `/etc/profile` in a text editor and add the following
   lines at the end:

   ```bash
   JAVA_HOME=/usr/local/java/jdk1.8.0_51
   PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
   export JAVA_HOME
   export PATH
   ```

6. Configure the system alternatives for Java executables:

   ```bash
   sudo update-alternatives --install "/usr/bin/java" "java" "/usr/local/java/jdk1.8.0_51/bin/java" 1
   sudo update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java/jdk1.8.0_51/bin/javac" 1
   sudo update-alternatives --install "/usr/bin/javaws" "javaws" "/usr/local/java/jdk1.8.0_51/bin/javaws" 1
   ```

7. Set the newly installed Oracle JDK as the default:

   ```bash
   sudo update-alternatives --set java /usr/local/java/jdk1.8.0_51/bin/java
   sudo update-alternatives --set javac /usr/local/java/jdk1.8.0_51/bin/javac
   sudo update-alternatives --set javaws /usr/local/java/jdk1.8.0_51/bin/javaws
   ```

8. Reload the profile to apply the environment variables in your current session:

   ```bash
   source /etc/profile
   ```

9. Reboot your system.

10. Verify the installation:
    ```bash
    java -version
    ```
