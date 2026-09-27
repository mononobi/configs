# Resolving Divergent Branches During Git Rebase

If your IDE reports a divergent branches error when attempting to rebase onto another
branch, temporarily configure pull behavior to rebase.

---

## Instructions

1. Configure rebase for the current project:

   ```bash
   git config pull.rebase true
   ```

2. Perform the rebase operation using your IDE or terminal.

3. Once the rebase is complete, restore the default behavior:
   ```bash
   git config pull.rebase false
   ```
