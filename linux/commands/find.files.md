# Advanced File Search with `find`

Find, filter, and batch-copy files based on creation and modification timestamps.

---

## Time-Based Search

### Find Files Created or Modified After a Specific Date

```bash
# Created on or after date:
find . -newerct YYYY-MM-DD -name "*.jpg"

# Modified on or after date:
find . -newermt YYYY-MM-DD -name "*.jpg"
```

### Find Files Within a Date Range

```bash
# Created between start date and end date:
find . -newerct YYYY-MM-DD ! -newerct yyyy-mm-dd -name "*.jpg"

# Modified between start date and end date:
find . -newermt YYYY-MM-DD ! -newermt yyyy-mm-dd -name "*.jpg"
```

### Find Files by Age (Days Ago)

```bash
# Created exactly N days ago:
find . -ctime N -name "*.jpg"

# Modified exactly N days ago:
find . -mtime N -name "*.jpg"
```

---

## Batch Processing & Exporting

### Save File List to Text

```bash
find . -newermt YYYY-MM-DD -name "*.jpg" >> list.txt
```

### Copy Listed Files to a Target Directory

```bash
# Recommended: Fast copy using xargs
xargs -a list.txt cp -t FOLDER_NAME/

# Alternative: Bash loop
for file in $(<list.txt); do cp "$file" FOLDER_NAME/; done

# Alternative: Shell expansion (suitable for smaller lists)
cp $(<list.txt) FOLDER_NAME/
```
