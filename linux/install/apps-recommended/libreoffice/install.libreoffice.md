# LibreOffice Installation and Configuration

## Installation

If you are on a distribution that already includes LibreOffice (e.g., Ubuntu-based), you should first remove the current version.

### 1. Remove the Existing Version

Run the following commands to remove the current version of LibreOffice:

```bash
sudo apt-get remove --purge libreoffice*
sudo apt-get clean
sudo apt-get autoremove
```

### 2. Install the Latest Version

Add the up-to-date repository and install LibreOffice:

```bash
sudo add-apt-repository ppa:libreoffice/ppa
sudo apt update
sudo apt install libreoffice
```

## Configuration

### Enable Right-to-Left (RTL) Languages

To enable right-to-left languages, follow these steps:

1. Open one of the LibreOffice apps.
2. Go to **Tools -> Options -> Language and Locales -> General**.
3. Check **Complex text layout** and choose your right-to-left language.
4. Restart the app.
5. Go to **Tools -> Options -> Language and Locales -> Complex Text Layout**.
6. Select **Numerals** as **Context**.
