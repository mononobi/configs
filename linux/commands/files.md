# File & Filesystem Inspection Commands

Commands for checking file sizes, disk usage, and directory contents.

| Command                  | Description                                                                        |
| :----------------------- | :--------------------------------------------------------------------------------- |
| `stat <FILE_OR_DIR>`     | Display detailed file/directory metadata (inode, size, permissions, timestamps)    |
| `du -h <FILE_OR_DIR>`    | Display disk space usage for a specific file or directory in human-readable format |
| `df -h`                  | Display disk usage and available capacity for all mounted filesystem partitions    |
| `ls <DIR_PATH> \| wc -l` | Count the total number of files inside a directory                                 |
