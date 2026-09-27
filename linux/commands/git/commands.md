# Common Git Commands Cheat Sheet

A quick reference guide for everyday Git operations, branch management, history
inspection, and configuration.

---

## Branch Management

| Command                                                 | Description                                                |
| :------------------------------------------------------ | :--------------------------------------------------------- |
| `git branch -a`                                         | List all local and remote tracking branches                |
| `git checkout -b <new_branch>`                          | Create a new branch from current HEAD and switch to it     |
| `git checkout <branch_name>`                            | Switch workspace to an existing local branch               |
| `git checkout -b <local_branch> origin/<remote_branch>` | Check out a remote tracking branch into a new local branch |
| `git branch -d <branch_name>`                           | Safely delete a local branch (if merged)                   |
| `git branch -D <branch_name>`                           | Force delete a local branch regardless of merge status     |
| `git push origin --delete <branch_name>`                | Delete a branch on the remote repository                   |

---

## Remote & Repository Operations

| Command                               | Description                                                                    |
| :------------------------------------ | :----------------------------------------------------------------------------- |
| `git remote -v`                       | List all configured remote repositories and URLs                               |
| `git clone <repo_url> .`              | Clone a remote repository into the current directory                           |
| `git pull`                            | Fetch and merge changes from the tracking remote branch into the active branch |
| `git checkout HEAD .`                 | Discard all unstaged local file modifications and restore deleted files        |
| `git remote set-url origin <new_url>` | Update the remote repository URL for `origin`                                  |

---

## History & Audit

| Command                                                          | Description                                                 |
| :--------------------------------------------------------------- | :---------------------------------------------------------- |
| `git shortlog -sne --since="01 Jan 2015" --before="01 Feb 2015"` | Display commit counts grouped by author within a date range |

---

## Author & Identity Configuration

### Via CLI

```bash
# Configure identity for the current repository only:
git config user.name "Your Name"
git config user.email "you@example.com"

# Configure identity globally across all repositories:
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
```

### Via `.git/config`

You can also set repository-specific identity directly inside the project's `.git/config`
file:

```ini
[user]
	email = you@example.com
	name = Your Name
```
