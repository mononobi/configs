# Multi-User Shared Directory Configuration

Create a shared filesystem directory where all local users belonging to a shared group have
read, write, and execute permissions with `setgid` inheritance.

---

## Step-by-Step Setup

1. **Create Target Directory**:

   ```bash
   sudo mkdir /home/share
   ```

2. **Create Shared User Group**:

   ```bash
   sudo addgroup share_group
   ```

3. **Add Users to the Shared Group**:

   ```bash
   sudo adduser <USER_NAME> share_group
   ```

4. **Assign Group Ownership**:

   ```bash
   sudo chown -R :share_group /home/share
   ```

5. **Configure Permissions and `setgid`**: Assign `2770` permissions (`rwxrws---`):

   ```bash
   sudo chmod -R 2770 /home/share
   ```
   - `2` (setgid bit): Ensures newly created files and subdirectories automatically inherit the
     `share_group` group ownership.
   - `770`: Owner and group members receive read, write, and directory execution access; other
     users have no access.

6. **Apply Membership**: Users must log out and log back in for new group membership to take
   effect.
