# what: sed — stream editor; transform text line by line (substitute, delete, print ranges)
# status: trying
# tags: linux, text, editing, automation
# last-used: 2026-10-15

## What this is

`sed` is a **stream editor**: it reads text one line at a time, applies the
editing rules you give it, and prints the result. You use it to make the same
change across a file (or thousands of files) without opening an editor — perfect
for scripts and remote servers where there's no GUI.

## Why a sysadmin uses this on the job

- **Edit config files in place during automation.** "Change `port = 80` to
  `port = 8080` in every server's config" — no human opens the file.
- **Pull out exactly the lines you need** from a big file (one line, a range,
  everything between two markers).
- **Clean up text** — strip lines, join lines, delete a block.

Because it edits non-interactively, `sed` is a backbone of shell scripts and
config-management glue.

## Key syntax

```
sed [flags] 'SCRIPT' [file...]
```

- `-n` — quiet: don't auto-print every line (you print explicitly with `p`)
- `-i` — edit the file **in place** (writes changes back to disk)
- `-i.orig` — edit in place but first save a backup named `file.orig`
- `-e` — add a script command; use several for multi-step scripts
- `-r` / `-E` — extended regex

Common script commands:

- `s/old/new/` — substitute first match on each line; `s/old/new/g` for all
  matches on the line
- `p` — print the current line (usually with `-n`)
- `d` — delete (don't print) the current line
- `10p` — act on line 10; `2,5d` — act on lines 2 through 5
- `/regex/` — address lines matching a regex; `/start/,/end/` — a range between
  two matches
- `/start/,+4d` — from the match, this line plus the next 4

### The newline trick (advanced)

```
sed ':a;N;$!ba;s/\n/ /g' file
```

Reads: make a label `a`; `N` appends the next line into the working buffer;
`$!ba` means "if not the last line, go back to `a`"; finally substitute every
newline with a space. Net effect: join the whole file into one line. You rarely
write this from scratch — recognize it and keep it in your notes.

## How to read the output

By default `sed` streams the whole (possibly edited) text to the screen. With
`-n` plus `p`, you only see what you explicitly printed. With `-i`, you see
**nothing** — the change went to the file, so check the file afterward.

## Common mistakes

- **`-i` with no backup is irreversible.** If the substitution is wrong, the
  original is gone. Use `-i.orig` while learning, and test the command without
  `-i` first to preview.
- **GNU vs BSD/macOS `sed` differ.** On macOS, `-i` needs an argument:
  `sed -i '' ...`. On Linux (GNU), `-i` alone is fine. The example script notes
  this.
- **Unescaped delimiters.** If your pattern contains `/`, either escape them or
  switch the delimiter: `s#/old/path#/new/path#`.
- **Greedy `s///` without `g`** only replaces the *first* match per line.

## Job-relevant depth

### Capture groups and back-references — the real power of `s///`
You can capture part of the match and reuse it in the replacement. In basic
regex the groups are `\( ... \)` and the refs are `\1`, `\2`; with `-E` they're
bare `( ... )`.
```
# Swap "user: name" into "name <user>":
sed -E 's/user: (\w+)/\1 <user>/' file
# Comment out a setting by name, keeping its value visible:
sed -E 's/^(max_connections.*)/# \1/' my.cnf
# & in the replacement means "the whole match" — wrap matches in brackets:
sed 's/[0-9]\+/[&]/g' file
```
Back-references are how you *rewrite* config lines instead of just deleting them,
which is most of real config-management work.

### Addressing with regex, not just line numbers
- `/pattern/s/old/new/` — only substitute on lines matching `pattern`.
- `/pattern/d` — delete matching lines; `/a/,/b/d` — delete the block from the
  first `a` line to the next `b` line.
- `$` means the last line; `0~3` (GNU) every 3rd line; `1~2` odd lines.
- Add `!` to invert: `/pattern/!d` keeps *only* matching lines (a grep in sed).

### Other commands worth knowing
- `a\ text` append, `i\ text` insert, `c\ text` change a line.
- `y/abc/xyz/` — transliterate characters (like `tr`).
- `-s` treat multiple input files separately; `-z` NUL-separated records.
- Multiple edits: `sed -e 's/a/b/' -e 's/c/d/'` or separate with `;`.

## Reading tricky output

- With `-n`, output is *only* what you `p`rint — silence means your address
  matched nothing.
- `sed: -e expression #1, char N: unterminated s command` almost always means a
  `/` inside your pattern needs escaping, or you want a different delimiter.
- After `-i`, there is **no output** — the change went to disk. Always `cat` or
  `grep` the file afterwards to confirm.

## Common troubleshooting

- **"My pattern has slashes in it."** Switch the delimiter: `s#/old/path#/new#`
  — any character can follow `s`.
- **"It only replaced the first one on the line."** Add the `g` flag:
  `s/old/new/g`.
- **"It worked on my Mac but not the server (or vice-versa)."** GNU vs BSD sed:
  BSD `-i` needs an argument (`-i ''`), and `\+`, `\|`, `\d` behave differently.
  For portable in-place edits many people use `perl -i -pe` instead.
- **"I nuked the config."** Always test without `-i` first, and use `-i.orig` so
  there's a backup. Script it as: edit a copy, `diff` it, *then* move it in.

## Combine it

`sed` is the *transform* stage between a filter and an action:
```
# Extract just the value of a setting from a config:
grep '^port' app.conf | sed -E 's/^port\s*=\s*//'

# Turn a messy list into a clean, de-duplicated one:
sed 's/#.*//; s/[[:space:]]*$//' list.txt | grep . | sort -u

# Rewrite a port across every .conf a find turned up (preview then apply):
find /etc/myapp -name '*.conf' -print0 | xargs -0 sed -n 's/8080/9090/p'  # preview
# find /etc/myapp -name '*.conf' -print0 | xargs -0 sed -i.orig 's/8080/9090/g'  # apply
```
That last pair is the safe real-world pattern: run the `-n ...p` **preview**
over all the files first, read it, and only then swap in `-i.orig` to apply.

## sudo / root?

Reading/previewing needs no root. Writing in place (`-i`) to a file you don't
own — like something in `/etc` — needs sudo, and it's a real system change. A
bad in-place edit to a config can take a service down, so **always practice in a
throwaway VM** and keep a backup (`-i.orig`).
