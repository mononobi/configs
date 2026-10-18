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

Create an account on the `bitwarden.eu` server. For the password, always choose the maximum
length of `50` characters and generate a strong and random value using this command:

```bash
openssl rand -base64 50 | head -c 50; echo
```

> Important: This password is your master password, meaning that it is not only used to log you
> in to your account, it is also used as the encryption key to encrypt the access key to your
> Bitwarden vault. So it needs to be strong so that even if Bitwarden servers got compromised
> and the stored credentials were stolen, the attacker cannot easily find out the encryption
> key (the master password) and decrypt the stored credentials.

> [!NOTE] The master password is only used when you are logged out of your account. For
> every-day use where you are already logged in to your account, you will use another password
> called `PIN` to unlock the app and see your saved credentials.

> [!TIP] **Use a 15 to 20-word passphrase instead of random gibberish characters:** Instead of
> 50 random characters, it is recommended to use a passphrase composed of **15 to 20 random
> words** (e.g. using Diceware / EFF wordlists, separated by hyphens). A 15 to 20-word
> passphrase provides ~194 to 258 bits of entropy (matching Bitwarden's 256-bit Argon2id
> ceiling and mathematically uncrackable by any computer). More importantly, real words
> eliminate typo-prone and ambiguous characters (`0` vs `O`, `1` vs `l`, symbols), making it
> vastly easier and safer to write down on paper and type when disaster recovery is needed.

### Secure The Master Password

When you run the Bitwarden installer (`install.bitwarden.sh` or through the main installer), it
automatically:

1. Copies the `bitwarden-info` template to `~/.bitwarden/bitwarden-info` with private user
   permissions (`600`).
2. Creates symbolic links in `~/.local/bin/` for `bitwarden-lock`, `bitwarden-unlock`, and
   `bitwarden-copy`, making them executable from anywhere.

#### 1. Fill in Your Credentials

Open the template in your preferred text editor:

```bash
nano ~/.bitwarden/bitwarden-info
```

Replace all `<no_value:...>` placeholders with your real account credentials:

- Your generated 50-character Master Password
- Your email address
- GPG Encryption Key / Passphrase description
- Web / Desktop / Extension and Mobile PINs
- Account fingerprint phrase
- Two-step recovery code

> [!IMPORTANT] Do not leave any `<no_value:...>` fields in the file. The `bitwarden-lock`
> script scans for these placeholders and will abort if any remain.

#### 2. Encrypt The Info File (`bitwarden-lock`)

Run the lock command from anywhere in your terminal:

```bash
bitwarden-lock
```

The script will automatically perform several safety checks:

- **Presence Check:** Ensures `~/.bitwarden/bitwarden-info` exists and is non-empty.
- **Placeholder Check:** Verifies that no `<no_value:...>` placeholders remain.
- **Overwrite Protection:** If `~/.bitwarden/bitwarden-info.gpg` already exists, it asks
  whether to overwrite (`yes/y or no/n` explicit, with no default).
- **AES-256 Encryption:** Prompts you for a passphrase using GPG symmetric encryption. On the
  Gnome popup, enter your passphrase and **DO NOT** select the `Save in the password manager`
  checkbox.

  > [!TIP] **Use a 6 to 8-word passphrase for the GPG key:** For your GPG key, it is better to
  > use a memorable passphrase composed of **6 to 8 random words** (e.g.
  > `cactus-orbit-velvet-falcon-meadow-timber-lantern-echo`) rather than random gibberish
  > characters. With GPG's enforced **65,011,712 S2K iterations**, an 8-word passphrase (~103
  > bits of entropy) would require **41 quintillion years** to crack on dedicated GPU clusters,
  > while remaining effortless for you to remember in your head and quick to type in the
  > terminal when unlocking.

- **Permission Hardening:** Automatically restricts ownership and permissions:
  ```bash
  sudo chown root:root ~/.bitwarden/bitwarden-info.gpg
  sudo chmod 600 ~/.bitwarden/bitwarden-info.gpg
  sudo chown root:root ~/.bitwarden
  sudo chmod 755 ~/.bitwarden
  ```
- **Plaintext Deletion:** Prompts whether to securely delete the unencrypted `bitwarden-info`
  file (`yes/y or no/n` explicit, with no default).

#### 3. View Your Credentials (`bitwarden-unlock`)

Whenever you need to view your master password and account details, run from anywhere:

```bash
bitwarden-unlock
```

Enter your `sudo` password and GPG passphrase when prompted to decrypt and display your
credentials.

> [!NOTE] When you decrypt the GPG file once, GPG caches the key for 15 minutes. On consecutive
> usages within that window, you will only need to authenticate with `sudo`.

> [!IMPORTANT] The `bitwarden-info.gpg` file is your master recovery vault. Keep multiple
> backup copies on secure external drives. Make sure to apply the same `root:root` ownership
> and `600` permissions to any backup copies.

#### 4. Inspect Vault Encryption Metadata (Optional)

You can inspect the OpenPGP packet headers and encryption parameters of your vault with this
command:

```bash
sudo gpg -v --list-packets ~/.bitwarden/bitwarden-info.gpg
```

Look for the symmetric key packet header (`:symkey enc packet:`):

```text
:symkey enc packet: version 4, cipher 9, s2k 3, hash 10
	salt a1b2c3d4e5f60718, count 65011712 (255)
```

Key fields explained:

- **`cipher 9` (AES-256):** The symmetric cipher algorithm (`9 = AES-256`, `8 = AES-192`,
  `7 = AES-128`).
- **`s2k 3` (Salted & Iterated):** String-to-Key mode 3, which salts and heavily iterates the
  passphrase hashing to prevent precomputed dictionary or rainbow table attacks.
- **`hash 10` (SHA-512):** The cryptographic hash function used for the key derivation function
  (`10 = SHA-512`, `8 = SHA-256`, `2 = SHA-1`).
- **`count 65011712` (Maximum Iteration Count):** The maximum iteration count allowable under
  OpenPGP standards (encoded as byte `255`). This exponentially increases the computing time
  required for any offline GPU brute-force attempt, while running in a fraction of a second
  during normal decryption.

#### 5. Distribute Encrypted Vault Copies (`bitwarden-copy`)

To distribute or back up your encrypted vault to external drives, backup partitions, or USB
flash drives:

```bash
bitwarden-copy /media/mono/USB_DRIVE /mnt/backup_drive
```

The script will automatically:

- Verify that your source vault (`~/.bitwarden/bitwarden-info.gpg`) exists. If missing, it
  instructs you to run `bitwarden-lock` first.
- Create a `.bitwarden/` subfolder inside each specified destination path.
- Prompt for overwrite confirmation (`yes/y or no/n` explicit, with no default) if
  `bitwarden-info.gpg` already exists at any destination.
- Copy `bitwarden-info.gpg` and apply the same strict ownership and permissions (`root:root`,
  `chmod 600` for the file, and `chmod 755` for the directory).
- Gracefully skip any invalid or non-existent destination paths and continue processing the
  remaining paths.

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

Go to the [Bitwarden](https://vault.bitwarden.eu/#/vault) website and log in with your master
password. Then go to the settings:

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
>
> - Every few weeks, you may need your `Master Password` on these platforms to log in, but not
>   every day.
> - By choosing a strong `Master Password`, your saved credentials on Bitwarden are secured by
>   a hard to crack encryption key while you can conveniently log in to different apps using
>   `PIN` or `Fingerprint`.

### Set Bitwarden as the Only Password Manager & Autofill Provider:

This will set Bitwarden as the only password manager and autofill provider on your system. This
includes the passwords, payment methods, addresses, and passkeys autosave and autofill
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
- **Ask to add item:** `Off` (It can be left `On`, however, because there is an annoying
  behavior where Bitwarden will ask to add credentials for some apps which already have
  credentials saved in Bitwarden, it is better to turn this off to avoid the annoyance of these
  popups)

  > Note: To make autofill also available for the apps (not just the browser), you need to add
  > the Android app URI into the list of `Autofill options (Websites)` in the entry of that app
  > in the Bitwarden vault. For example, for the Twitter app, you also need to add both
  > `androidapp://com.twitter.android` and `com.twitter.android` into the list. You can find
  > the app URI by going to the app's page on the Play Store and looking for the `id` parameter
  > in the URL. For example, for Twitter, the URL is
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

> Important: **DO NOT** turn on the `Make Bitwarden your default password manager` option in
> the browser extension settings because it will cause some issues with the autofill feature of
> the extension. It is better to keep this option off and just rely on the browser's built-in
> autofill management to set Bitwarden as the default password manager as explained in the
> previous sections.

> Settings → Notifications

- **Ask to save and use passkeys:** `On`
- **Ask to add login:** `On`
- **Ask to update existing login:** `On`

> Note: To use the autofill feature in `Incognito mode` or `Private Windows` as well, you need
> to allow the Bitwarden extension to run in these modes from the browser's extension
> management page.

### Important Note:

- Never store any information about your Bitwarden account into the Bitwarden vault itself. For
  these kinds of information (i.e. master password, app PINs, etc.) always use the
  `bitwarden-info` local file and encrypt it with GPG as explained in the steps above.
- **DO NOT** create a passkey for your Bitwarden account not to compromise the security of your
  account.
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
