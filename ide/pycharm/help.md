# PyCharm Configuration & UI Freeze Fix

Guidelines for deploying tuned PyCharm settings and resolving UI freezing issues on Linux
distributions.

---

## 1. Configuration Directory Placement

Place the `config` folder into your PyCharm user settings directory:

- **Newer PyCharm Versions**:
  ```bash
  ~/.config/JetBrains/PyCharm*/
  ```
- **Older PyCharm Versions**:
  ```bash
  ~/.PyCharm*/
  ```

---

## 2. Preventing UI Freezes (`vmoptions`)

- `original.vmoptions` contains the unoptimized default JVM options which trigger recurring UI
  freezes on certain Linux desktop environments and window managers.
- The tuned `vmoptions` provided in the `config` directory has been optimized to eliminate UI
  freezes.
- If your system has limited physical RAM, adjust heap allocation flags (`-Xms`, `-Xmx`)
  accordingly. _(Note: UI freezing is caused by rendering pipeline threading, not RAM limits)._
