# GPG Key Management & Git Commit Signing Guide

GPG (GNU Privacy Guard) keys cryptographically sign and verify data, documents, and code
commits (such as verified commits on GitHub or GitLab).

---

## 1. Installation & Prerequisites

Install required tools:

```bash
sudo apt install -y gpg pass
```

Verify the installed GPG version:

```bash
gpg --version
```

---

## 2. Generate a GPG Key Pair

Generate a robust public/private key pair:

```bash
gpg --full-gen-key
```

When prompted:

1. **Algorithm**: Choose `(1) RSA and RSA` (default).
2. **Key Length**: Enter `4096` bits.
3. **Key Validity**: Enter `0` (`key does not expire`).
4. **User Identification**:
   - **Real Name**: The name used to reference the key (`KEY_USER_NAME`).
   - **Email Address**: The email associated with your commits (`KEY_EMAIL`).
5. **Passphrase**: Provide a strong passphrase to protect your secret key.

---

## 3. Retrieve Key Details & Key ID

Display secret keys with long hexadecimal IDs:

```bash
gpg --list-secret-keys --keyid-format LONG KEY_EMAIL
```

### Example Output:

```text
sec   rsa4096/30F2B65B9246B6CA 2017-08-18 [SC]
      D5E4F29F3275DC0CDA8FFC8730F2B65B9246B6CA
uid                   [ultimate] KEY_USER_NAME <KEY_EMAIL>
ssb   rsa4096/B7ABC0813E4028C0 2017-08-18 [E]
```

The **Key ID** is the 16-character string immediately following `rsa4096/` on the `sec`
line (e.g., `30F2B65B9246B6CA`).

---

## 4. Export the Public Key

Export the ASCII-armored public key to paste into GitHub, GitLab, or key servers:

```bash
gpg --armor --export <KEY_ID>
```

_(You can redirect output to a file: `gpg --armor --export <KEY_ID> > gpg.pub`)_

---

## 5. Key Listing & Deletion

### List Keys

```bash
# List public keys:
gpg --list-keys

# List private (secret) keys:
gpg --list-secret-keys
```

### Delete a Key Pair

Delete both secret and public components in order:

```bash
gpg --delete-secret-key "KEY_USER_NAME"
gpg --delete-key "KEY_USER_NAME"
```

> [!NOTE]  
>
> GPG stores configuration, keyrings, and trust databases in `~/.gnupg`.

---

## 6. Using a Single Key with Multiple Email Addresses

To sign commits across personal and work repositories with a single GPG key and have both
show as **Verified** on GitHub/GitLab, attach additional email identities to the key:

1. Edit the key:

   ```bash
   gpg --edit-key <KEY_ID>
   ```

2. Add a new user ID:

   ```text
   adduid
   ```

   Fill in the real name, work email address, and optional comment, then confirm.

3. Set trust for the new user ID:

   ```text
   uid <SECOND_KEY_EMAIL>
   trust
   ```

   Select `5 = I trust ultimately` and confirm.

4. Save changes and publish key:
   ```text
   save
   ```
   Upload the updated key:
   ```bash
   gpg --send-keys <KEY_ID>
   ```
