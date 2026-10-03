# psycopg2 Dependencies & Installation Guide

Complete guide for installing and compiling `psycopg2` for PostgreSQL connectivity in Python.

---

## 1. Quick Decision: Binary vs. Source

Python provides two distinct packages on PyPI for `psycopg2`:

| Package                 | Package Name      | Compiles C Code?              | Host Dependencies Needed?                     | Recommended Environment         |
| :---------------------- | :---------------- | :---------------------------- | :-------------------------------------------- | :------------------------------ |
| **Pre-compiled Binary** | `psycopg2-binary` | **No** (pre-built wheel)      | **None**                                      | **Local Development & Testing** |
| **Source Build**        | `psycopg2`        | **Yes** (compiles with `gcc`) | `build-essential`, `libpq-dev`, `python3-dev` | **Production Deployments**      |

---

## 2. Local Development (No Compilation Needed)

For quick development, experimentation, local scripts, and simple environments, you **do not
need** to install any C compilers or system development libraries.

Install the official pre-compiled binary package:

```bash
pip install psycopg2-binary
```

- Installs instantly in 1–2 seconds.
- Bundles its own pre-compiled libraries.
- Requires no system `gcc`, `libpq-dev`, `python3-dev`, or `pg_config`.

---

## 3. Production Deployments (Source Build Recommended)

For production systems, the official psycopg maintainers explicitly recommend compiling
`psycopg2` from source:

```bash
pip install psycopg2
```

### Why Source Compilation is Recommended for Production

1. **Avoids "Dual OpenSSL" Collisions & Segfaults**: `psycopg2-binary` ships with its own
   statically bundled OpenSSL. If another Python package (such as `cryptography`, `requests`,
   or an LDAP driver) loads the system OpenSSL into the same Python process, conflicting
   symbols can cause random **Segmentation Faults (crashes)** or silent TLS handshake failures.
   Building from source guarantees that all libraries share the exact same host system OpenSSL.
2. **Automatic OS Security Updates**: When Ubuntu releases security patches for `libpq5` or
   `libssl`, running standard `sudo apt update && sudo apt upgrade` immediately patches your
   running Python application without needing to rebuild or redeploy your Python virtual
   environments.
3. **Enterprise Authentication Support**: Source builds link directly against system Kerberos
   (GSSAPI), PAM, and custom SSL engines configured on the host machine.

---

## 4. Required System Build Dependencies for Source Build

To build `psycopg2` from source, the host system requires three components:

1. **C Compiler & Toolchain (`build-essential`)**: Provides `gcc`, `make`, and standard C
   runtime headers.
2. **PostgreSQL C Client Library & Headers (`libpq-dev`)**: Provides `libpq-fe.h`, `libpq.so`,
   and the `/usr/bin/pg_config` compiler helper.
3. **Python C Header Files (`python3-dev`)**: Provides `Python.h` needed to compile Python C
   extensions.

### Automated Setup

Run the included automated installer to configure all three dependencies at once:

```bash
./install.psycopg2.sh
```

Or manually via APT:

```bash
sudo apt-get update
sudo apt-get install -y build-essential libpq-dev python3-dev
```

Once the dependencies are installed, install `psycopg2`:

```bash
pip install psycopg2
```

---

## 5. How `pg_config` Works with Dockerized PostgreSQL

- **`pg_config` is a build-time compiler tool**, not a database server connection tool. It
  simply tells `pip` where `libpq` header and library files are located on your host.
- When `libpq-dev` is installed on your host, `/usr/bin/pg_config` is placed directly in your
  `$PATH`.
- Once `psycopg2` finishes compiling on your host, it connects over standard network TCP
  (`localhost:5432`) to PostgreSQL running inside Docker (or any remote database server)
  seamlessly.
