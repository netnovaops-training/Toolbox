# what: practice exercises for lesson 02 — grep, sed, awk, perl
# status: trying
# tags: linux, practice, text, grep, sed, awk, perl
# last-used: 2026-10-15

# Practice — Text Processing

Do these in a throwaway VM or container. Make your own sample files first (a
small fake log and a small fake config work well). When a task edits a file,
**preview first** and keep a backup — there's no undo for an in-place edit.
These are hints, not solutions; lean on each subfolder's `doc.md` and
`man grep` / `man sed` / `man awk` / `perldoc perlrun`.

## Easy

1. **Filter a log.** From a log file, show only the lines containing `ERROR`,
   with line numbers.
   - Hint: `grep`, `-n`.

2. **Show the real config.** Print a config file with comment lines and blank
   lines removed, so only actual settings remain.
   - Hint: `grep -v` with an OR pattern for `^\s*#` and `^$` (use `-E`).

3. **Grab one column.** From columnar output (e.g. `username ip port` lines),
   print just the last column.
   - Hint: `awk`, `$NF`.

## Medium

4. **Count per value.** From a log or data file, tally how many times each
   value in a column appears (e.g. hits per IP).
   - Hint: `awk` with an array `count[$1]++` and an `END { }` block.

5. **Extract a line range.** Print lines 10 through 20 of a file — two ways:
   once with `sed`, once with `perl`.
   - Hint: `sed -n '10,20p'`; `perl -ne 'print if 10 .. 20'`.

6. **Safe in-place replace.** Change every whole word `old` to `new` in a
   config file, keeping a backup of the original.
   - Hint: preview with no `-i` first; then `sed -i.orig` or `perl -i.orig`,
     and remember word boundaries `\b`.

7. **Find long lines.** Print every line longer than 80 characters, prefixed
   with its line number.
   - Hint: `awk 'length($0) > 80 { ... }'`.

## Harder

8. **Delete a block.** Remove everything between a line matching `start` and a
   line matching `end` (markers included), writing to a new file so the
   original survives.
   - Hint: `perl -ne 'print unless /start/ .. /end/'`, or a `sed` range.

9. **Join a file into one line.** Collapse a whole file onto a single line,
   with spaces where the newlines were.
   - Hint: the `sed ':a;N;$!ba;s/\n/ /g'` idiom — read your `sed/doc.md` for
     what each piece means.

10. **Build a mini report.** From a log, show the top 5 most frequent values of
    some column, most frequent first.
    - Hint: `awk` to tally into an array and print `count value`, then pipe to
      `sort -nr` and `head -n 5`.

11. **Mixed pipeline.** Combine tools: `grep` to narrow to the lines you care
    about, `awk` to pull a column, `sort | uniq -c | sort -nr` to rank them.
    - Hint: each `|` hands its output to the next tool's input. Build it one
      stage at a time and check the output before adding the next pipe.

## Employment-grade

12. **Top client IPs from an access log (combines grep + sort + uniq).** Make a
    small fake access log. Extract just the client IP from each line and produce
    a ranked list of the busiest IPs, most requests first.
    - Hint: `grep -oE` with an IP regex, then `sort | uniq -c | sort -nr`. Could
      you do the same extraction with `awk '{print $1}'`? Try both.

13. **Bytes served per IP (awk aggregation).** From the same log, total the
    bytes column *grouped by* IP (not just a count), then rank it.
    - Hint: `awk '{ bytes[$1] += $NF } END { for (ip in bytes) print bytes[ip], ip }'`
      then `sort -nr`. Why can't plain `uniq -c` do this?

14. **Errors per hour (combines grep + awk/cut + sort + uniq).** Count how many
    error lines fall in each hour of the day.
    - Hint: `grep` the error level, pull the `HH` out of the timestamp (`awk`,
      `cut -c`, or `grep -o`), then `sort | uniq -c`.

15. **Safe multi-file config rewrite (combines find + sed/perl).** You have
    several `.conf` files that all set a port to `8080`. Change it to `9090`
    across all of them — but *preview* every change first and keep a backup of
    each file.
    - Hint: `find ... -print0 | xargs -0 sed -n 's/8080/9090/p'` to preview,
      then swap to `sed -i.orig` (or `perl -i.orig -pe`) to apply. Never apply
      before you've read the preview.

16. **Rewrite a line instead of deleting it (capture groups).** In a config,
    comment out the `max_connections` line while keeping its value visible on
    the commented line.
    - Hint: capture the whole line with `()` / `\( \)` and put `# ` before `\1`
      (sed) or `$1` (perl). Preview with no `-i` first.

17. **Strip a multi-line block (perl slurp mode).** Remove an HTML/XML comment
    `<!-- ... -->` that spans several lines, writing the result to a new file.
    - Hint: line-by-line tools can't see across newlines; `perl -0777 -pe
      's/<!--.*?-->//gs'`. Why does the `?` (non-greedy) matter here?

18. **Poor-man's join (awk two-file trick).** Given an allow-list of IPs in one
    file and a log in another, print only the log lines whose IP is on the list.
    - Hint: `awk 'NR==FNR { ok[$1]; next } ($1 in ok)' allow.txt log.txt`. Read
      the `doc.md` note on `NR` vs `FNR` to see why this works.
