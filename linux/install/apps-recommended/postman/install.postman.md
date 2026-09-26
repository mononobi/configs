# Postman Installation

## Recommended Installation (Flatpak)

Flatpak is the recommended way to install Postman:

```bash
flatpak install flathub com.getpostman.Postman
```

### Troubleshooting Certificate Errors

If Postman crashes when clicking on its icon and does not open at all, run this to see the error:

```bash
flatpak run com.getpostman.Postman
```

If the error is related to certificates not being found, execute these commands:

```bash
cd ~/.var/app/com.getpostman.Postman/config/Postman/proxy
openssl req -subj '/C=US/CN=Postman Proxy' -new -newkey rsa:2048 -sha256 -days 365 -nodes -x509 -keyout postman-proxy-ca.key -out postman-proxy-ca.crt
```

Now the app should start without any issues.

## Snap Installation (Not Recommended)

> **Warning:** You can also install using Snap, but it's not recommended at all as it has terrible performance.

```bash
snap install postman --classic --channel=v9/stable
```

Always check for the latest channel before installing:

```bash
snap info postman
```
