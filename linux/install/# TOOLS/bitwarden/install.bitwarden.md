## Bitwarden Password Manager

### Install The Desktop App

```bash
flatpak install flathub com.bitwarden.desktop
```

### Install The Browser Extension

#### Chrome:
[Bitwarden Chrome Extension](https://chromewebstore.google.com/detail/bitwarden-password-manage/nngceckbapebfimnlniiiahkandclblb?hl=en)

#### Firefox:
[Bitwarden Firefox Extension](https://addons.mozilla.org/en-US/firefox/addon/bitwarden-password-manager/)

### Install The Android App

[Bitwarden Android App](https://play.google.com/store/apps/details?id=com.x8bit.bitwarden&hl=en)

### Create an Account

Create an account on the `bitwarden.eu` server.
For the password, always choose the maximum length of `50` characters and generate a
strong and random value using this command:

```bash
openssl rand -base64 50 | head -c 50; echo
```

> Important: This password is your master password, meaning that it is not only used
> to log you in to your account, it is also used as the encryption key to encrypt
> the access key to your Bitwarden vault. So it needs to be strong so that even if Bitwarden
> servers got compromised and the stored credentials were stolen, the attacker cannot
> easily find out the encryption key (the master password) and decrypt the stored credentials.

> Note: The master password is only used when you are logged out of your account. For every-day
> use where you are already logged in to your account, you will use another password called
> `PIN` to unlock the app and see your saved credentials.

### Secure The Master Password

Run this commands to create a folder and a file to store the master password:
```bash
mkdir -p ~/.bitwarden/
touch ~/.bitwarden/bitwarden-info
```

Copy the master password you generated into the `bitwarden-info` file.
You can also add other information about your account in this file such as the email address 
you used to create the account, and any other relevant information.

Run this command to encrypt the `bitwarden-info` file with a memorable but still strong password.
```bash
sudo gpg --symmetric --cipher-algo AES256 ~/.bitwarden/bitwarden-info
```

A Gnome popup will ask you for a passphrase. This is the `secondary key` for this specific file. 
Make it something simple but still strong and unique that you can remember. To see your
master password, you need to know this `secondary key`.

> Note: On the Gnome popup, **DO NOT** select the `Save in the password manager` checkbox.

A GPG encrypted file called `bitwarden-info.gpg` will be created.

Run these commands to limit the access to the GPG file to the root user (**sudo**):
```bash
sudo chown root:root ~/.bitwarden/bitwarden-info.gpg
sudo chmod 600 ~/.bitwarden/bitwarden-info.gpg
sudo chown root:root ~/.bitwarden
sudo chmod 755 ~/.bitwarden
```

> Now the file is encrypted and only the root user can read it. A regular user
> cannot read, write, delete, copy, or move the GPG file. This also applies to
> the `~/.bitwarden` directory.

Run this command to see you master password by decrypting the GPG file:
```bash
sudo gpg --decrypt ~/.bitwarden/bitwarden-info.gpg
```

If you were successful to decrypt the GPG file, go ahead and delete the 
original `bitwarden-info` file (**not the GPG file**):
```bash
sudo rm ~/.bitwarden/bitwarden-info
```

> Important: The `bitwarden-info.gpg` file is your only gate to log in to your bitwarden account.
> Keep multiple copies of it on different drives and mediums. Since it is both encrypted and also
> limited to the root user, it is safe to have multiple copies of it in different places.
> Make sure to apply the same set of permissions to all copies of the GPG file as mentioned above.

> Note: You can copy the `bitwarden-unlock` script into the local `bin` folder to
> be able to unlock the GPG file by a single command from anywhere.

> Note: When you decrypt the GPG file once, it will remain unlocked for the next 15 minutes.
> So on consecutive usages of the decryption command within 15 minutes, you will only
> need to enter your user's password for the `sudo` command.

```bash
cp bitwarden-unlock ~/.local/bin/
chmod +x ~/.local/bin/bitwarden-unlock
```

Run this command in the terminal from anywhere to unlock the master password GPG file:
```bash
bitwarden-unlock
```

### Configure The Desktop App:

Login to the desktop app using the master password. Then go to the settings:

> File -> Settings:

- **Session Timeout:** `On system lock`
- **Timeout action:** `Lock`
- **Unlock with PIN:** `On` (Set a memorable PIN)
  - **Lock with master password on restart:** `Off` (You mostly log in using your PIN)
- **Clear clipboard:** `5 minutes`
- **Theme:** `Dark`

### Configure On The Web:

Go to the [Bitwarden](https://vault.bitwarden.eu/#/vault) website and log in with your 
master password. Then go to the settings:

> Settings -> Security:

> Session Timeout Tab:
- **Timeout:** `15 minutes`
- **Timeout action:** `Lock`

> Master Password Tab:
- **Log in with passkey:** `Off`

> Two-Step Login Tab:
- **Email:** `Active`
- **Authenticator app:** `Active`

> Keys Tab:
- **Algorithm:** `Argon2id`
- **KDF iterations:** `5`
- **KDF memory (MB):** `256`
- **KDF parallelism:** `8` (Number of the CPU core count of your system)

### Configure The Browser Extension:

> Settings -> Account Security:
- **Unlock with PIN:** `On`
  - **Require master password on browser restart:** `Off` (You mostly log in using your PIN)
- **Session timeout:** `On browser restart`
- **Timeout action:** `Lock`

### Configure The Android App:

> Settings:

> Account security:
- **Unlock with Biometrics:** `On`
- **Unlock with PIN code:** `On`
  - **Require master password on app restart:** `On`
- **Allow authenticator syncing:** `On`
- **Session timeout:** `15 minutes`
- **Session timeout action:** `Lock`

> Other:
- **Allow sync on refresh:** `On`
- **Clear clipboard:** `5 minutes`
- **Allow screen capture:** `Off`

### Summary

With this setup, to log in to different apps, you mostly need:

- **Website:** `Master Password`
- **Browser Extension:** `PIN`
- **Android App:** `Fingerprint`
- **Desktop App:** `PIN`

> Note: 
> - Every few weeks, you may need your `Master Password` on these platforms to log in, but
> not every day.
> - By choosing a strong `Master Password`, your saved credentials on Bitwarden are
> secured by a hard to crack encryption key while you can conveniently log in to
> different apps using `PIN` or `Fingerprint`.

### Set Bitwarden as the Only Password Manager & Autofill Provider:
This will set Bitwarden as the only password manager and autofill provider on your system.
This includes the passwords, payment methods, addresses, and passkeys autosave and autofill 
features.

#### Android:
> Settings → Passwords, passkeys & accounts
- **Preferred service:** `Bitwarden`
- **Additional services:** `Off`

#### Chrome on Android:
> Settings → Google Password Manager → Settings (Gear Icon)
- **Offer to save passwords:** `Off`
- **Automatically create a passkey to sign in faster:** `Off`
- **Auto Sign-in:** `Off`

> Settings → Payment methods
- **Save and fill payment methods:** `Off`

> Settings → Addresses and more
- **Save and fill addresses:** `Off`

> Settings → Autofill services
- **Autofill using another service:** `On`

#### Firefox on Android:
> Settings → Passwords
- **Save passwords:** `Never Save`
- **Autofill in Firefox:** `Off`
- **Autofill in other apps:** `Off`

> Settings → Autofill
- **Save and fill addresses:** `Off`
- **Save and fill payment methods:** `Off`

#### Bitwarden App on Android:
> Settings → Autofill
- **Autofill services:** `On`
- **Use Chrome autofill integration:** `On`
- **Ask to add item:** `Off` (It can be left `On`, however, because there is an annoying behavior
  where Bitwarden will ask to add credentials for some apps which already have credentials saved 
  in Bitwarden, it is better to turn this off to avoid the annoyance of these popups)

  > Note: To make autofill also available for the apps (not just the browser), you need
  > to add the Android app URI into the list of `Autofill options (Websites)` in the entry 
  > of that app in the Bitwarden vault.
  > For example, for the Twitter app, you also need to add both `androidapp://com.twitter.android` 
  > and `com.twitter.android` into the list. 
  > You can find the app URI by going to the app's page on the Play Store and looking for 
  > the `id` parameter in the URL. For example, for Twitter, the URL is 
  > `https://play.google.com/store/apps/details?id=com.twitter.android&hl=en`, so the app URI 
  > is `com.twitter.android`.

#### Chrome on Desktop:
> Settings → Autofill and passwords → Google Password Manager → Settings (Gear Icon)
- **Offer to save passwords and passkeys:** `Off`
- **Sign in automatically:** `Off`

> Settings → Autofill and passwords → Payment methods
- **Save and fill payment methods:** `Off`

> Settings → Autofill and passwords → Addresses and more
- **Save and fill addresses:** `Off`

> Settings → Autofill and passwords → Enhanced autofill
- **Enhanced autofill:** `Off`

#### Firefox on Desktop:
> Settings → Privacy & Security → Passwords
- **Ask to save passwords:** `Off`

> Settings → Privacy & Security → Payment methods
- **Save and autofill payment info**:** `Off`

> Settings → Privacy & Security → Addresses and more
- **Save and autofill addresses:** `Off`

#### Browser Extension (Chrome & Firefox):
> Settings → Autofill
- **Show autofill suggestions on form fields:** `On`
- **Display identities as suggestions:** `On`
- **Display cards as suggestions:** `On`
- **Make Bitwarden your default password manager:** `OFF`

> Important:
> **DO NOT** turn on the `Make Bitwarden your default password manager` option in the 
> browser extension settings because it will cause some issues with the autofill 
> feature of the extension. It is better to keep this option off and just rely on 
> the browser's built-in autofill management to set Bitwarden as the default password 
> manager as explained in the previous sections.

> Settings → Notifications
- **Ask to save and use passkeys:** `On`
- **Ask to add login:** `On`
- **Ask to update existing login:** `On`

> Note: To use the autofill feature in `Incognito mode` or `Private Windows` as well, 
> you need to allow the Bitwarden extension to run in these modes from the browser's 
> extension management page.

### Important Note:

- Never store any information about your Bitwarden account into the Bitwarden vault itself. 
  For these kinds of information (i.e. master password, app PINs, etc.) always use 
  the `bitwarden-info` local file and encrypt it with GPG as explained in the steps above.
- **DO NOT** create a passkey for your Bitwarden account not to compromise the security of 
  your account.
- If you do want to absolutely create a passkey for your Bitwarden account, make sure to store 
  the passkey in a secure place `outside` Bitwarden (e.g. Google Password Manager, ...).

### A Rare Bug With Passkeys on Wayland:

#### The Bug:

When a website asks for a passkey, the Bitwarden popup window might instantly close or lose 
focus before you can click "Save" or "Authenticate".

#### The Fix:

If this happens, click the "Pop Out" button (the little square with an arrow) in the top-right 
corner of the Bitwarden extension menu before you click "Log in with Passkey" on the website. 
This forces Bitwarden into its own dedicated Wayland window, ensuring the passkey handshake 
completes perfectly.
