# Install PyQt5 Designer

To install Qt Creator and PyQt5 development tools, run the following command:

```bash
sudo apt-get install qtcreator pyqt5-dev-tools
```

## Convert `.ui` files to Python

To convert created UI files from Qt Designer into Python code, execute:

```bash
pyuic5 file.ui -o file.py
```

After conversion, you can import `file.py` into your PyQt5 application.
