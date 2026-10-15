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
