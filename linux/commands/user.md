# Linux User & Group Administration

Commands for managing users, groups, sudo privileges, and account details.

---

## User Management

| Action                                               | Command                                         |
| :--------------------------------------------------- | :---------------------------------------------- |
| **List all users on system**                         | `cut -d: -f1 /etc/passwd`                       |
| **Add a new user**                                   | `sudo adduser <USERNAME>`                       |
| **Remove a user**                                    | `sudo userdel <USERNAME>`                       |
| **Remove user home directory**                       | `sudo rm -r /home/<USERNAME>`                   |
| **Change account username**                          | `sudo usermod -l <NEW_USERNAME> <OLD_USERNAME>` |
| **Change user password**                             | `sudo passwd <USERNAME>`                        |
| **Modify user finger info (Full name, room, phone)** | `sudo chfn <USERNAME>`                          |

---

## Group Management & Sudo Privileges

| Action                               | Command                                                                  |
| :----------------------------------- | :----------------------------------------------------------------------- |
| **Add user to sudo group**           | `sudo usermod -aG sudo <USERNAME>` _(or `sudo adduser <USERNAME> sudo`)_ |
| **Add user to supplementary group**  | `sudo usermod -aG <GROUP_NAME> <USERNAME>`                               |
| **List groups for user**             | `groups <USERNAME>`                                                      |
| **Show user UID and group IDs**      | `id <USERNAME>`                                                          |
| **List members of a specific group** | `getent group <GROUP_NAME>`                                              |
| **List all groups on system**        | `getent group \| cut -d: -f1` _(or `less /etc/group`)_                   |
| **Create a new group**               | `sudo groupadd <GROUP_NAME>`                                             |
