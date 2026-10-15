# what: perl (as a one-liner tool) — fast search/replace and line editing from the command line
# status: trying
# tags: linux, text, regex, editing, automation
# last-used: 2026-10-15

## What this is

Perl is a full programming language, but sysadmins most often use it as a
**command-line one-liner** for text surgery — especially search-and-replace
across files. Its regex engine is powerful and consistent, and its `-i`
in-place editing is reliable across systems, which is why many people reach for
`perl -pe` where they'd otherwise fight with `sed` portability quirks.

## Why a sysadmin uses this on the job

- **Bulk find-and-replace** across many config files, with a backup, in one
  command.
- **Line-range editing** — keep or drop lines N through M, delete the first N
  lines, extract a block between two markers.
- **Whitespace / formatting fixes** — tabs to spaces, collapse blank lines.
- **Quick counts** — lines and characters — without extra tools.

It shines when `sed`'s syntax gets awkward or when you want the same behaviour
on Linux, BSD, and macOS.

## Key syntax

The command-line flags do the heavy lifting:

- `-e 'CODE'` — the program to run
- `-n` — loop over input lines but **don't** auto-print (you print explicitly)
- `-p` — loop over input lines and **do** auto-print each after running CODE
- `-i` — edit files **in place**; `-i.orig` makes a `.orig` backup first
- `-l` — handle line endings for you (chomp input, add newline on print)
- `-0` / `-00` — change the input record separator; `-00` is "paragraph mode"
  (records separated by blank lines)

Inside the code, the current line is `$_`. Useful variables:

- `$.` — current line number
- `s/old/new/` — substitute on `$_`; add `g` for all matches, `\b` for word
  boundaries
- `.. ` (the range operator) — `print if 10 .. 20` prints lines 10–20;
  `print unless /^foo$/ .. /^bar$/` drops the block between markers

## How to read the output

With `-p` the (possibly edited) text streams to the screen. With `-n` you only
see what you `print`. With `-i` you see **nothing** — the file was changed, so
check the file. A count one-liner prints its summary from an `END { }` block.

## Common mistakes

- **`-i` without a backup is irreversible.** Use `-i.orig` while learning and
  preview with `-p` (no `-i`) first.
- **`-p` vs `-n`.** `-p` auto-prints (good for substitutions); `-n` is silent
  (good when you decide what to print). Mixing them up gives doubled or missing
  output.
- **Word boundaries.** `s/foo/bar/g` also hits `foobar`. Use `\bfoo\b` to match
  the whole word only.
- **Shell quoting.** Keep the program in single quotes so the shell doesn't
  expand `$_`, `$.`, or `$1`.

## Job-relevant depth

### Why perl where sed struggles
- **Portable `-i`.** `perl -i.orig -pe '...'` behaves the same on Linux, BSD,
  and macOS — no `sed -i ''` surprise. For scripts that must run anywhere, this
  alone is a reason to use perl.
- **A richer regex engine.** Lookahead `(?=...)`, lookbehind `(?<=...)`,
  non-greedy `.*?`, named captures `(?<name>...)`, `\d \w \s`, and modifiers
  like `/x` (whitespace-insensitive) all work out of the box.
- **Multi-line / whole-file mode.** `perl -0777 -pe 's/.../.../gs'` slurps the
  *entire file* into `$_` so a regex can span lines — something line-based sed
  can't do without the awkward `:a;N` loop.

### Capture groups and `-a` autosplit
```
perl -pe 's/(\w+)=(\w+)/$2=$1/' file       # swap key and value using $1 $2
perl -lane 'print $F[0], " ", $F[-1]' file # -a splits into @F; -F',' for CSV
perl -ne 'print "$1\n" if /status=(\d+)/' log   # extract just the capture
```
`-a` gives you `@F` (like awk's fields); `-F'pattern'` sets the split. `$F[0]`
is the first field, `$F[-1]` the last. This turns perl into an awk-style tool.

### Useful flags together
- `-l` chomps input newlines and re-adds them on print — stops double/missing
  newlines. `-n`/`-p` loop; `-e` is the code; `-M` loads a module.
- `-00` paragraph mode (records split on blank lines); `-0777` whole-file slurp.

## Reading tricky output

- With `-n` you see only what you `print`; with `-p` the line auto-prints after
  your code runs. Doubled output usually means you printed *and* used `-p`.
- `-i` prints nothing — the file changed on disk; `cat` it to confirm.
- A regex that silently matches nothing often means an unescaped metacharacter
  or a `\b` boundary that didn't fall where you expected.

## Common troubleshooting

- **"Can't do inplace edit: ... "** on BSD/macOS — you need a backup suffix.
  `perl -i.bak -pe` is the portable, always-safe form.
- **Shell ate my `$1`/`$_`.** Keep the program in **single** quotes so the shell
  leaves perl's variables alone; use `-e` once per code chunk.
- **"My multi-line regex didn't match across lines."** Default mode is
  line-by-line; add `-0777` to slurp the file and `/s` so `.` matches newlines.
- **Greedy match grabbed too much.** Use the non-greedy `.*?`.

## Combine it

perl shines as the *transform*, but it pipes like everything else:
```
# Extract a captured field and rank it:
perl -ne 'print "$1\n" if /"(?:GET|POST) (\S+)"/' access.log \
  | sort | uniq -c | sort -nr | head        # top requested paths

# Preview a multi-file replace that find selected, THEN apply with a backup:
find /etc/myapp -name '*.conf' -print0 | xargs -0 perl -ne 'print "$ARGV: $_" if /8080/'   # preview
# find /etc/myapp -name '*.conf' -print0 | xargs -0 perl -i.orig -pe 's/8080/9090/g'        # apply

# Whole-file edit: delete a <!-- ... --> block that spans lines:
perl -0777 -pe 's/<!--.*?-->//gs' page.html > page.clean.html
```
The safe pattern mirrors sed: run the **preview** (no `-i`) across all the files
`find` turned up, read it, and only then re-run with `-i.orig` to apply.

## sudo / root?

Previewing needs no root. In-place edits (`-i`) to files you don't own — e.g.
under `/etc` — need sudo and are real system changes. A wrong bulk replace can
break every config it touched at once, so **practice in a throwaway VM** and
keep the `.orig` backups.
