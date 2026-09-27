# Text and File Search Commands

Essential commands for searching text patterns inside files and locating files on the
filesystem.

| Command                                        | Description                                                                 |
| :--------------------------------------------- | :-------------------------------------------------------------------------- |
| `grep -R "<WORD>" <PATH>`                      | Recursively search file contents within `<PATH>` for `<WORD>`               |
| `grep -rnwl '/path/to/search/' -e '<PATTERN>'` | Search directory recursively and output only filenames matching `<PATTERN>` |
| `find <PATH> -name "<FILENAME>"`               | Search `<PATH>` for files matching `<FILENAME>`                             |
