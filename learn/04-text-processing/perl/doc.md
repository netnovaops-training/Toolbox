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

## sudo / root?

Previewing needs no root. In-place edits (`-i`) to files you don't own — e.g.
under `/etc` — need sudo and are real system changes. A wrong bulk replace can
break every config it touched at once, so **practice in a throwaway VM** and
keep the `.orig` backups.
