# what: grep — search text for lines matching a pattern (plain or regex)
# status: trying
# tags: linux, text, search, logs, regex
# last-used: 2026-10-15

## What this is

`grep` prints the lines that match a pattern. The pattern can be plain text or a
regular expression. It reads from files or from a pipe, so it's the universal
filter: "show me only the lines I care about."

## Why a sysadmin uses this on the job

This is probably the single most-run text tool in the job:

- **Log triage.** "Show me every ERROR in this log." "Show the log without the
  noise." Logs are huge; grep is how you find the needle.
- **Config inspection.** "Show this config file without comments and blank
  lines" so you can see what's actually set.
- **Code / config search.** "Where is this setting referenced?" across a whole
  directory tree.
- **Piping.** `lsof ... | grep LISTEN`, `ps aux | grep nginx` — grep is the
  second half of a thousand one-liners.

## Key syntax and flags

```
grep [flags] PATTERN [file...]
```

- `-r` / `-R` — recurse into directories (search a whole tree)
- `-n` — show line numbers
- `-i` — case-insensitive
- `-v` — **invert**: show lines that do *not* match
- `-E` — extended regex (lets you write `(INFO|WARN)` without backslashes);
  `egrep` is the same thing
- `-e PATTERN` — give a pattern explicitly; repeatable for multiple patterns
- `-I` — skip binary files
- `-s` — suppress "no such file" errors
- `--` — "end of options"; everything after is treated as a pattern/filename,
  which is how you search for strings that start with `-`

### Patterns: OR, and anchors

Several equivalent ways to match "INFO or WARN":

```
grep 'INFO\|WARN' file     # basic regex: escape the pipe
grep -E '(INFO|WARN)' file # extended regex: bare pipe
grep -e INFO -e WARN file  # two -e patterns
egrep 'INFO|WARN' file     # egrep = grep -E
```

Anchors: `^` = start of line, `$` = end of line. So `^$` is a blank line, and
`^[[:space:]]*#` is "a comment line, maybe with leading spaces."

## How to read the output

- Plain: one matching line per match.
- With `-n`: `42:the matching line` — number then colon then the line.
- With `-r` across files: `path/to/file:42:the line` — filename, number, line.
- With `-v`: you're seeing what was *left after* removing matches.

## Common mistakes

- **`grep foo *` with no matches in some files** prints "No such file or
  directory" noise — add `-s`, or search specific paths.
- **Regex vs plain text.** Characters like `.`, `*`, `(`, `|` are special. To
  match a literal dot, escape it `\.` or use `-F` (fixed strings / `fgrep`).
- **Forgetting `-r`** when you meant to search a directory — plain `grep` on a
  directory just warns and does nothing useful.
- **Leading dashes.** `grep -- --flag file` — without the `--`, grep thinks
  `--flag` is an option.

## sudo / root?

`grep` only reads. You need root only when the *file itself* is readable solely
by root (e.g. some files under `/var/log` or `/etc`). grep never changes
anything, so it's safe to run freely.
