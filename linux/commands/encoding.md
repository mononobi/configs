# Converting Text File Encodings with `iconv`

Convert subtitle files, text logs, or source code between character encodings using `iconv`.

## Syntax

```bash
iconv -f "<FROM_ENCODING>" -t "<TO_ENCODING>" "<INPUT_FILE>" -o "<OUTPUT_FILE>"
```

## Example

Convert a Windows Arabic/Persian (`windows-1256`) encoded subtitle file to universal `UTF-8`:

```bash
iconv -f "windows-1256" -t "UTF-8" Big.Eyes.sub9.fa-IR.srt -o Big.Eyes.sub9.utf8.fa-IR.srt
```
