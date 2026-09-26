# Install Python 3.7 from Source

## 1. Install Dependencies
Update your package list and install the required build dependencies:
```bash
sudo apt update
sudo apt install build-essential checkinstall zlib1g-dev libncursesw5-dev libncurses5-dev tk-dev libbz2-dev libgdbm-dev libnss3-dev libc6-dev openssl libssl-dev libreadline-dev libffi-dev wget libsqlite3-dev
```

## 2. Configure the Build
Configure the Python build with optimizations, loadable SQLite extensions, shared libraries, and framework enabled:
```bash
./configure --enable-optimizations --enable-loadable-sqlite-extensions --enable-shared --enable-framework
```

## 3. Compile Python
Compile the source code using multiple cores (replace `4` with your number of CPU cores):
```bash
make -j 4
```

## 4. Install Python
Choose one of the following installation methods:
* **Alternative Install (Recommended):** Generates a `python3.7` executable without replacing the default `python3` system binary.
  ```bash
  sudo make altinstall
  ```
* **Standard Install:** Overwrites the default `python3` system binary.
  ```bash
  sudo make install
  ```

## 5. Load Shared Libraries
Update the dynamic linker run-time bindings to load the newly installed shared libraries:
```bash
sudo ldconfig /usr/local/lib
```

## 6. Verify Installation
Check that the correct Python version is installed:
```bash
python3.7 --version
```

## 7. Install PIP (if necessary)
Install `pip` for Python 3:
```bash
sudo apt-get install python3-pip
```

Check the `pip` version:
```bash
pip3 --version
```
