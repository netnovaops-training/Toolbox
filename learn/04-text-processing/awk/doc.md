# what: awk — field-aware text processor; slice columns, filter rows, and compute
# status: trying
# tags: linux, text, columns, logs, reporting
# last-used: 2026-10-15

## What this is

`awk` reads text line by line and splits each line into **fields** (columns).
It then runs little rules of the form `pattern { action }`: if a line matches
the pattern, it does the action. This makes it the right tool whenever your data
has columns — logs, `ps`/`lsof` output, CSVs, `/etc` files.

Think of it as "grep that understands columns and can do math."

## Why a sysadmin uses this on the job

- **Pull one column out of command output.** "Give me just the PIDs" from
  `ps`, or just the filename column from `lsof`.
- **Filter rows by a computed condition.** "Lines longer than 80 chars",
  "requests bigger than 1 MB", "only non-blank lines."
- **Quick reports.** Count, sum, or tally without writing a whole script —
  e.g. "top commands from history", "hits per IP in a log."
- **Reformat** — reorder or relabel columns on the fly.

## Key syntax

```
awk 'pattern { action }' file
```

- If you omit the action, the default is `{ print }` (print the whole line).
- If you omit the pattern, the action runs on every line.

Built-in variables:

- `$0` — the whole line
- `$1`, `$2`, ... — field 1, field 2, ...
- `$NF` — the **last** field (`NF` = number of fields)
- `NR` — current line number across all input
- `FNR` — line number within the current file
- `-F','` — set the field separator (default is whitespace)

Patterns can be:

- `/regex/` — lines matching a regex (`!/regex/` for non-matching)
- `length($0) > 80` — any boolean expression
- `/start/,/end/` — a range between two matching lines
- `NF` — true when the line has at least one field (i.e. is non-blank)

Actions use `print`, `printf`, assignment, and arrays. `a[$0]++` is a famous
idiom: it counts how many times each line has been seen.

## How to read the output

Whatever your `print`/`printf` says. `print $2` gives one column. `print NR,
$0` prefixes the line number. `printf "%5d : %s\n", NR, $0` formats it with
padding. If you build a tally with an array, you usually `print` it in an
`END { ... }` block that runs after all input is read.

## Common mistakes

- **Wrong field separator.** Whitespace is the default; for CSV you need
  `-F','`. Forgetting this gives you one giant field.
- **Confusing `NR` and `FNR`.** `NR` keeps counting across multiple files;
  `FNR` resets per file.
- **Shell-quoting dates/variables** into an awk program (as in the Apache-log
  example) is fiddly — the shell expands `$(...)` *before* awk sees it. Read
  those slowly.
- **Expecting awk to edit files in place.** Classic awk prints to stdout; you
  redirect to a new file. (GNU awk has `-i inplace`, but don't rely on it.)

## sudo / root?

`awk` only reads and prints — no system change. You'd only need root to *read*
a file that's root-only (like some logs under `/var/log`). Safe to run freely.
