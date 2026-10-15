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

## Job-relevant depth

### Flags that save you during an incident
- `-C 3` (also `-A` after / `-B` before) — show **context** lines around each
  match. During log triage you almost always want the lines *around* the error,
  not just the error line. `grep -C5 ERROR app.log` is a daily move.
- `-o` — print only the matched part, not the whole line. The key to *extracting*
  with grep: `grep -oE '[0-9]{1,3}(\.[0-9]{1,3}){3}' access.log` pulls every IP.
- `-c` — count matching lines; `-m 5` — stop after 5 matches (fast on huge logs).
- `-w` — whole word (so `grep -w foo` doesn't hit `foobar`); `-x` — whole line.
- `-l` / `-L` — list files that *do* / *do not* contain a match (no lines shown).
- `-R --include='*.conf' --exclude-dir=.git` — recurse but scope it. `--include`
  and `--exclude-dir` are what make a tree-wide search usable.
- `-P` — Perl-compatible regex (GNU grep): lookahead, `\d`, `\s`, non-greedy
  `*?`. Reach for `-P` when `-E` can't express it.
- `-z` / `-Z` — NUL-separated, to pair safely with `find -print0` / `xargs -0`.

### grep -F and fixed strings
If you're searching for a literal string full of regex metacharacters (an IP, a
path, a version like `1.2.3`), `-F` (or `fgrep`) treats it literally and is
faster. No more escaping every `.`.

## Reading tricky output

- `-r` across files prints `path:line:text`; `--include` keeps that readable.
- `grep -c` prints `0` for files with no match — useful, but means "zero", not
  an error.
- With `-o`, you get one line *per match*, so a line with three matches becomes
  three output lines — perfect before `sort | uniq -c`.
- Exit status matters in scripts: grep returns `0` if it found something, `1` if
  not, `2` on error. `if grep -q PATTERN file; then ...` is the idiomatic test
  (`-q` = quiet, no output, just the exit code).

## Common troubleshooting

- **"Binary file matches" instead of the lines.** You hit a binary (or a file
  with a stray NUL); add `-a` to treat it as text or `-I` to skip binaries.
- **"My regex matched too much."** Basic regex (no `-E`) treats `+`, `?`, `{`,
  `(`, `|` as *literal* characters. Either escape them or use `-E`/`-P`.
- **"It's slow on a huge tree."** Scope with `--include`/`--exclude-dir`, or let
  `find` pick the files and pipe them in.

## Combine it

grep is the *filter* at the front of most log pipelines:
```
# Top 10 client IPs hitting your site (grep extracts, the rest ranks):
grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' access.log | sort | uniq -c | sort -nr | head

# Count errors per hour from a log:
grep ERROR app.log | awk '{print $2}' | cut -c1-2 | sort | uniq -c

# Search only tracked config files, with context, in a scoped tree:
grep -RnC2 --include='*.conf' --exclude-dir=.git 'timeout' /etc/myapp
```
The recurring pattern is `grep` to *narrow*, then `awk`/`cut` to *extract a
field*, then `sort | uniq -c | sort -nr` to *rank*. Build it one pipe at a time.

## sudo / root?

`grep` only reads. You need root only when the *file itself* is readable solely
by root (e.g. some files under `/var/log` or `/etc`). grep never changes
anything, so it's safe to run freely.
