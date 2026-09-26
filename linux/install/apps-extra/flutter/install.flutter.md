# Install Flutter

## Requirements

First, install the necessary requirements:

```bash
sudo apt-get install bash curl file git unzip xz-utils zip libglu1-mesa
```

> **Note:** You have to use a VPN and DNS changer to be able to download from Iran.

## Manual Installation

> **Note:** Installing Flutter using Snap (`sudo snap install flutter --classic`) does not work. Use manual installation instead.

1. **Download a stable release** from the [Flutter SDK Releases page](https://flutter.dev/docs/development/tools/sdk/releases?tab=linux).

   For example:

   ```bash
   wget https://storage.googleapis.com/flutter_infra/releases/stable/linux/flutter_linux_2.2.1-stable.tar.xz
   ```

2. **Extract the downloaded file** into your home directory. For example:

   ```bash
   mkdir ~/.flutter-sdk
   tar -xf flutter_linux_2.2.1-stable.tar.xz -C ~/.flutter-sdk
   ```

3. **Update your PATH** to include the Flutter SDK `bin` directory:

   Open `~/.bashrc`:

   ```bash
   vi ~/.bashrc
   ```

   Add the following line into the file. Replace `[PATH_OF_FLUTTER_GIT_DIRECTORY]` with the directory path of your SDK.

   ```bash
   export PATH="$PATH:[PATH_OF_FLUTTER_GIT_DIRECTORY]/bin"
   ```

   For example:

   ```bash
   export PATH="$PATH:/home/mono/.flutter-sdk/flutter/bin"
   ```

   Save and close the file, then run:

   ```bash
   source ~/.bashrc
   ```

4. **Verify the PATH configuration:**

   Execute this to check the PATH:

   ```bash
   echo $PATH
   ```

   Execute this to check the path of the Flutter and Dart binaries:

   ```bash
   which flutter
   which flutter dart
   ```

5. **Pre-download required dependencies** for Android and iOS:

   ```bash
   flutter precache
   ```

6. **Check dependencies:**

   Execute this to check that all required dependencies are met:

   ```bash
   flutter doctor -v
   ```

## Additional Configurations

### Desktop Support

Run this command to install extra dependencies for desktop support:

```bash
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev
```

### Enable Environments

Run these commands to enable Flutter for different environments:

```bash
flutter config --enable-web
flutter config --enable-linux-desktop
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-android
flutter config --enable-ios
```

To see current configs, run:

```bash
flutter config
```

## Updates

- To update the installed version of Flutter, run:

  ```bash
  flutter upgrade
  ```

- To only update the dependency packages that your app is using and not Flutter itself, run the following command from the root directory of your project:

  ```bash
  flutter pub upgrade
  ```
