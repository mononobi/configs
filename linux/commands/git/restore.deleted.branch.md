# Restoring a Completely Deleted Git Branch

Step-by-step guide to recover a Git branch that has been deleted both locally and
remotely.

---

## Method 1: Using `git reflog` (Fastest)

1. Inspect the repository reference log without truncation:

   ```bash
   git reflog --no-abbrev
   ```

2. Locate the commit hash corresponding to the tip of your deleted branch before deletion
   occurred.

3. Test and inspect the state of that commit:

   ```bash
   git checkout <SHA>
   ```

4. Once verified, create and switch to a new branch from that commit:
   ```bash
   git checkout -b <BRANCH_NAME>
   ```

---

## Method 2: Recovering Dangling Commits via `git fsck`

If the reflog has expired or been pruned, use `git fsck` to identify unreachable dangling
commits:

1. Scan for unreachable commits and dump their one-line summaries to a file:

   ```bash
   git fsck --full --no-reflogs --unreachable --lost-found | grep commit | cut -d' ' -f3 | xargs -n 1 git log -n 1 --pretty=oneline > .git/lost-found.txt
   ```

2. Open `.git/lost-found.txt` in an editor and search for commit messages from the deleted
   branch.

3. Check out candidate commit hashes to inspect code:

   ```bash
   git checkout <SHA>
   ```

4. Restore the branch from the recovered commit:
   ```bash
   git checkout -b <BRANCH_NAME>
   ```
