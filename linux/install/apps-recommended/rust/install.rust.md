# Rust Installation Guide

## Installation

Run the following command in your terminal to install Rust:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

To verify the installation, open a new terminal and run:

```bash
rustc --version
```

## Post-Installation

### Standard Library

To install the Rust standard library source, run:

```bash
rustup component add rust-src
```

### Updating

To keep your Rust toolchain up to date, use:

```bash
rustup update
```

### Uninstalling

If you need to uninstall Rust, run:

```bash
rustup self uninstall
```

## Directory Paths

The Rust toolchain and package manager installation paths are located at:

- `~/.rustup`
- `~/.cargo`

For more information, please visit the
[official Rust installation page](https://www.rust-lang.org/tools/install).

## Useful Subcommands

### `cargo expand`

Shows the result of macro expansion for a crate or a specific module.

**Installation:**

```bash
cargo install cargo-expand
```
