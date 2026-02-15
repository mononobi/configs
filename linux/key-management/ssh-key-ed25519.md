# SSH Key Management Guide (ed25519)

This guide provides a definitive, step-by-step process for creating and 
managing SSH keys using the secure ed25519 format.

## Glossary of Terms

In this guide, we will use the following terms:
*   **SOURCE_DEVICE_NAME**: The local machine name (e.g., your PC or laptop) where you generate 
    and store your SSH keys.
*   **SOURCE_USER**: The user account on your local device that owns the SSH keys.
*   **REMOTE_USER**: The user account on the remote server that you want to access using SSH.
*   **REMOTE_IP**: The IP address or hostname of the remote server you want to connect to.

## 1. Generate SSH Key on Your Local Device

Generate a new SSH key pair on your local machine. The ed25519 algorithm 
is recommended for its strong security properties.

```bash
ssh-keygen -t ed25519 -C "SOURCE_USER@SOURCE_DEVICE_NAME"
```

* Replace `SOURCE_USER` with your local username and `SOURCE_DEVICE_NAME` with a 
  descriptive name for the device (e.g., `laptop`).
*   When prompted, press Enter to accept the default file location (`~/.ssh/id_SOURCE_DEVICE_NAME`).
*   Enter a strong passphrase when prompted. This encrypts your private key and adds an 
    extra layer of security. Use a strong passphrase for the key.

This command creates two files in your `~/.ssh` directory:
*   `id_SOURCE_DEVICE_NAME`: Your private key (keep this secure and never share it).
*   `id_SOURCE_DEVICE_NAME.pub`: Your public key (this can be shared).

## 2. Copy Public Key to the Server

Transfer your public key to the remote server. This allows your local device to authenticate 
with the server using the key pair.

```bash
ssh-copy-id -i ~/.ssh/id_SOURCE_DEVICE_NAME.pub REMOTE_USER@REMOTE_IP
```

*   Replace `REMOTE_USER` with your username on the remote server and `REMOTE_IP` with 
    the server's IP address or hostname and `SOURCE_DEVICE_NAME` with the name you used 
    when generating the key.
*   You will be prompted for the server's password (if not already authenticated) to 
    complete the transfer.

This command appends your public key to the `~/.ssh/authorized_keys` file on the server.

## 3. Activate SSH Key on Your Local Device

To avoid entering your passphrase every time you connect, add your private key to the `ssh-agent`.

1.  Start the `ssh-agent` (if not already running):

    ```bash
    eval "$(ssh-agent -s)"
    ```

2.  Add your private key to the `ssh-agent`:

    ```bash
    ssh-add ~/.ssh/id_SOURCE_DEVICE_NAME
    ```

    *   You will be prompted for your key passphrase.

3. Create a `~/.ssh/config` file:
    ```bash
    touch ~/.ssh/config
    chmod 600 ~/.ssh/config
    ```

    * Open the `~/.ssh/config` file:
    ```bash
    nano ~/.ssh/config
    ```

    * Add these lines to the file for each destination server you want to connect to:
    ```text
    # Profile for the Server-1
    Host server-1
        HostName REMOTE_IP_1
        User REMOTE_USER_1
        IdentityFile ~/.ssh/id_SOURCE_DEVICE_NAME

    # Profile for the Server-2
    Host server-2
        HostName REMOTE_IP_2
        User REMOTE_USER_2
        IdentityFile ~/.ssh/id_SOURCE_DEVICE_NAME
    ```

    * Now, to connect to each server, instead of having to do this:
    ```bash
    ssh -i ~/.ssh/id_SOURCE_DEVICE_NAME REMOTE_USER_1@REMOTE_IP_1
    ```

    * You can just do this (Using the profile's `Host` field):
    ```bash
    ssh server-1
    ```

## 4. Secure SSH Key Files and Directory

Proper file permissions are crucial for SSH key security. Apply the following permissions 
on your local device:

*   **All key files (public and private) in `~/.ssh` directory:**
    *   Set to `600` access level (read/write for owner only).
    *   Owner must be the user.

    ```bash
    cd ~/.ssh
    chmod 600 *
    chown -R $(whoami):$(whoami) *
    ```

*   **The `~/.ssh` folder itself:**
    *   Set to `700` access level (read/write/execute for owner only).
    *   Owner must be the user.

    ```bash
    chmod 700 ~/.ssh
    chown -R $(whoami):$(whoami) ~/.ssh
    ```

## 5. Enhance Server Security with `999_sshd_config_secure.conf`

To further secure your server, it is highly recommended to disable password-based authentication 
and other less secure methods. The file [999_sshd_config_secure.conf](./999_sshd_config_secure.conf) 
provides a secure configuration for your SSH daemon.

This configuration file sets the following directives:
*   `PermitRootLogin no`: Prevents direct root login via SSH.
*   `PasswordAuthentication no`: Disables password-based authentication, forcing 
     key-based authentication.
*   `ChallengeResponseAuthentication no`: Disables challenge-response authentication.
*   `UsePAM no`: Disables Pluggable Authentication Modules (PAM) for SSH.

**To use this configuration:**

*Always ensure you have key-based access working before disabling password authentication 
to avoid locking yourself out of the server.*

1.  Remove any existing configuration files.
2.  Create a configuration file for `sshd` on the server.
3.  Copy the content of [999_sshd_config_secure.conf](./999_sshd_config_secure.conf)
    to the created `/etc/ssh/sshd_config.d/999_sshd_config_secure.conf` file on your server.
4.  Restart the SSH service to apply the changes.

    ```bash
    sudo rm -f /etc/ssh/sshd_config.d/*.conf
    sudo touch /etc/ssh/sshd_config.d/999_sshd_config_secure.conf
    sudo nano /etc/ssh/sshd_config.d/999_sshd_config_secure.conf
    ```
    
    > Important:
    > - Keep the file name starting with `999_` to ensure it is loaded after any other 
    >   possibly present SSH configuration files, allowing it to override less secure settings.
    > - Remove any existing `*.conf` files under `/etc/ssh/sshd_config.d/`. Some
    >   Cloud providers (e.g., AWS) may have default SSH configurations that could override 
    >   your settings. Ensure that only your secure configuration file is present in the directory.

    After editing and saving the file, run this:
    ```bash
    sudo systemctl daemon-reload
    sudo systemctl restart ssh
    sudo systemctl reload ssh
    sudo systemctl restart ssh.socket
    ```

    *Now you should not be able to make an SSH connection to the server 
    using the username and password or the root user.*

## 6. SSH Key Best Practices

Understanding how to manage SSH keys effectively is crucial for maintaining security 
across your devices and servers.

*   **Key Per Source Device (**Recommended**):** Each local device (e.g., your PC, your laptop) 
    should have its own unique SSH key pair. This establishes a distinct identity for each device. 
    If one device is compromised, only its specific key is affected, limiting the blast radius.

*   **Key Per Destination (**Misunderstanding**):** It is a common misunderstanding that you should 
    create a new SSH key for each server you connect to. This is not recommended. Instead, a 
    single SSH key from a source device can, and should, be used to connect to multiple 
    destination servers. The public key of your source device's SSH key is simply added to 
    the `authorized_keys` file on each server you wish to access. This simplifies management 
    and maintains the "identity" of your source device across all your connections.

## 7. Adding SSH Key to Git Repositories (GitHub/GitLab)

To use your SSH key for authenticating with Git hosting services like GitHub or GitLab, 
you need to add your public key to your account settings on these platforms.

### 7.1. Copy Your Public SSH Key

First, retrieve the content of your public key.

```bash
cat ~/.ssh/id_SOURCE_DEVICE_NAME.pub
```

Copy the entire output, which starts with `ssh-ed25519` and ends with your source device name.

### 7.2. Add Public Key to GitHub/GitLab

1.  **GitHub:**
    *   Go to your GitHub settings: `https://github.com/settings/keys`
    *   Click on "New SSH key" or "Add SSH key".
    *   Provide a descriptive title for your key (e.g., "My Laptop SSH Key").
    *   Paste the copied public key content into the "Key" field.
    *   Click "Add SSH key".

2.  **GitLab:**
    *   Go to your GitLab settings: `https://gitlab.com/-/user_settings/ssh_keys`
    *   Paste the copied public key content into the "Key" field.
    *   Provide a descriptive title for your key.
    *   Optionally, set an expiration date for the key.
    *   Click "Add key".

### 7.3. Configure Local Git Repository to Use SSH

If your local Git repository is currently configured to use HTTPS for remote operations, you 
should change it to SSH to leverage your newly added SSH key.

1.  **Check current remote URL:**
    Navigate to the root directory of your local Git repository and run:

    ```bash
    git remote -v
    ```

    If the output shows URLs starting with `https://github.com/` or `https://gitlab.com/`, your 
    repository is using HTTPS.

2.  **Change remote URL to SSH:**
    To switch to SSH, use the following command, replacing `USERNAME` and `REPOSITORY` with your 
    actual Git username and repository name:

    ```bash
    git remote set-url origin git@github.com:USERNAME/REPOSITORY.git
    # Or for GitLab:
    # git remote set-url origin git@gitlab.com:USERNAME/REPOSITORY.git
    ```

3.  **Verify the change:**
    Run `git remote -v` again to confirm that the remote URL now starts with `git@github.com:` 
    or `git@gitlab.com:`.

    ```bash
    git remote -v
    ```

    The output should now look like `origin  git@github.com:USERNAME/REPOSITORY.git` (fetch) 
    and `origin  git@github.com:USERNAME/REPOSITORY.git` (push).
