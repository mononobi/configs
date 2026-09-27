# PostgreSQL Cluster & Version Administration

System paths, cluster lifecycle tools, and version inspection commands.

---

## System File Locations

| Component               | Path                                 |
| :---------------------- | :----------------------------------- |
| **Binaries & Clusters** | `/usr/lib/postgresql/<VERSION_NUM>/` |
| **Configurations**      | `/etc/postgresql/<VERSION_NUM>/`     |
| **Data Directory**      | `/var/lib/postgresql/<VERSION_NUM>/` |
| **Log Files**           | `/var/log/postgresql/`               |

---

## Cluster Management Commands

```bash
# Start / Stop all PostgreSQL clusters:
sudo service postgresql start
sudo service postgresql stop

# View all installed clusters:
pg_lsclusters

# Rename an existing cluster:
sudo pg_renamecluster <version_num> <current_name> <new_name>

# Upgrade cluster data to newly installed major PostgreSQL version:
sudo pg_upgradecluster <old_version_num> <current_name>

# Drop / delete a cluster:
sudo pg_dropcluster <VERSION_NUM> <name>
```

---

## Version Inspection

Navigate to `/usr/lib/postgresql/<VERSION_NUM>/bin`:

```bash
# Server version:
./postgres -V

# Client CLI version:
./psql -V
```
