# Microsoft SQL Server Post-Installation Configuration

Enable TCP/IP networking protocols and restart services following a fresh SQL Server
installation.

---

## Steps

1. Open Start Menu and search for:
   ```text
   SQL Server <YEAR> Configuration Manager
   ```
2. In the left pane, navigate to:
   ```text
   SQL Server Network Configuration > Protocols for MSSQLSERVER
   ```
3. In the right pane, double-click **TCP/IP** and set **Enabled** to **Yes**.
4. In the left pane, select **SQL Server Services**.
5. Restart the following services:
   - **SQL Server (MSSQLSERVER)**
   - **SQL Server Agent (MSSQLSERVER)**
