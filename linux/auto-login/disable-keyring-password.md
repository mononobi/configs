# Disable Keyring Password on Auto-Login

If you have configured your account for automatic login and want to prevent being prompted
for the keyring password every time the system starts, follow the steps below.

> [!WARNING]  
>
> Disabling the keyring password requirement is a security risk. All stored passwords and
> credentials will be saved unencrypted and accessible to anyone with physical access to
> your logged-in session.

## Steps to Disable the Keyring Password

1. Open the **Passwords and Keys** application (also known as `seahorse`).
2. In the left sidebar under **Passwords**, right-click on the **Login** keyring and
   select **Change Password**.
3. Enter your **Current Password** (by default, this matches your user account login
   password) and press **Enter**.
4. Leave both the **New Password** and **Confirm Password** fields completely empty and
   press **Enter** (or click **Continue**).
5. If prompted with a warning about storing passwords unencrypted, confirm and proceed.
