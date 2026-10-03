# GPG Commit Signing Configuration

Configure Git to cryptographically sign commits using GPG keys for verified badges on GitHub or
GitLab.

---

## Prerequisites

Generate a public/private GPG key pair and upload your public key to your GitHub/GitLab
account. Refer to `linux/key-management/alternate-key-types/GPG.md` for key generation
instructions.

---

## Configuration Steps

### 1. Specify Your GPG Signing Key

Associate your GPG Key ID with Git:

```bash
# Recommended: Set globally across all repositories
git config --global user.signingkey <KEY_ID>

# Or set locally for the current repository only
git config user.signingkey <KEY_ID>
```

### 2. Enable Automatic Commit Signing

Configure Git to automatically sign all commits by default:

```bash
# Recommended: Enable globally
git config --global commit.gpgsign true

# Or enable locally for current repository
git config commit.gpgsign true
```
