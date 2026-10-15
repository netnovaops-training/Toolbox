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

## Job-relevant depth

### BEGIN / END and real aggregation
`awk` runs an optional `BEGIN { }` before any input and `END { }` after all of
it. That's where reports live:
```
# Sum a column and print the total + average:
awk '{ sum += $3 } END { print "total", sum, "avg", sum/NR }' data
# Set up headers/separators once in BEGIN:
awk 'BEGIN { FS=":"; OFS=" -> " } { print $1, $7 }' /etc/passwd
```
`FS` is the input separator (same as `-F`), `OFS` the output separator, `RS`/`ORS`
the record separators. Setting them in `BEGIN` keeps the program clean.

### Counting and tallying idioms (interview gold)
- `a[$1]++` — count occurrences per key; print in `END` for a frequency table.
- `!seen[$0]++` — print each line only the first time (de-dupe, order kept).
- `sum[$1] += $2` — sum one column grouped by another (e.g. bytes per IP).
- `END { for (k in a) print a[k], k }` — dump an associative array.

### Conditions, math, and functions
Full expressions work: `$3 > 500`, `$1 ~ /^10\./` (field matches regex),
`$2 != "OK"`. Numeric fields auto-convert. Handy functions: `length($0)`,
`substr($0,1,8)`, `split($3, parts, ":")`, `gsub(/x/, "y", $0)`,
`printf "%-10s %5d\n", $1, $2` for aligned columns.

### Multiple files and NR vs FNR
`NR` counts across all input; `FNR` resets per file. The two-file trick
`awk 'NR==FNR { a[$1]; next } ($1 in a)' keys.txt data.txt` keeps only the
`data.txt` rows whose first field appeared in `keys.txt` — a poor-man's join.

## Reading tricky output

- A tally printed from `END { for (k in a) ... }` comes out in **no guaranteed
  order** — pipe to `sort` to rank it.
- If every line prints as one big field, your `FS` is wrong (CSV needs `-F,`).
- `print a, b` puts `OFS` (a space by default) between them; `print a b` glues
  them with nothing. That missing comma is a classic bug.

## Common troubleshooting

- **"My `$(date)` / shell variable didn't reach awk."** The shell expands it
  before awk runs, and single quotes block it. Pass values in with `-v
  name=value` instead: `awk -v today="$(date +%F)" '$1==today'`.
- **"Numbers sorted as text."** awk compares numerically only in a numeric
  context; force it with `+0` (`$3+0 > 500`) or sort downstream with `sort -n`.
- **"CSV with quoted commas broke."** awk's `-F,` doesn't understand quoted
  fields. For real CSV use a CSV-aware tool; awk is for clean columnar data.

## Combine it

awk is the *extract/compute* stage in the middle of a pipeline:
```
# Top 5 IPs in an access log (awk pulls the field, the rest ranks):
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -5

# Total bytes served per status code:
awk '{ bytes[$9] += $10 } END { for (s in bytes) print s, bytes[s] }' access.log

# Memory hogs from ps, sorted, nicely formatted:
ps aux | awk 'NR>1 { print $4"%", $11 }' | sort -rn | head
```
Rule of thumb: `grep` narrows, `awk` picks the column or does the math,
`sort | uniq -c | sort -nr` ranks. awk can do the tally *itself* with an array —
use that when you also need a sum or an average, not just a count.

## sudo / root?

`awk` only reads and prints — no system change. You'd only need root to *read*
a file that's root-only (like some logs under `/var/log`). Safe to run freely.
