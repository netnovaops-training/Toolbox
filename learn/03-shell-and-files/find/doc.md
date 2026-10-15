# what: find — search the filesystem by name, size, time, owner, permissions, and act on matches
# status: trying
# tags: linux, filesystem, search, sysadmin
# last-used: 2026-10-15

## What this is

`find` walks a directory tree and tests every file and directory against the
conditions you give it. If a thing matches, `find` prints it — or runs a command
on it. It is the Swiss-army knife for "where is that file / which files match X /
do something to all of them."

## Why a sysadmin uses this on the job

This is one of the most-used tools in the job. Real tasks:

- "The disk filled up — find every file over 500 MB."
- "What changed in the last hour?" (after an incident or a bad deploy)
- "Fix the permissions on this whole web directory."
- "Find every file owned by a user we're offboarding."
- "Find world-writable or setuid files" (a security audit staple).

It replaces hours of clicking with one line, and it scales to millions of files.

## Key syntax

The shape is always:

```
find  <where>  <tests>  <action>
```

- `<where>` — a starting path, e.g. `.` (here), `/`, `/var/www`
- `<tests>` — filters, combined left to right (implicitly ANDed)
- `<action>` — default is `-print`; others are `-delete`, `-exec`, `-execdir`

Common tests:

- `-type f` (file), `-type d` (directory)
- `-name '*.conf'` (glob on the name; quote it so the shell doesn't expand it),
  `-iname` for case-insensitive
- `-size +20M` (bigger than 20 MB; `-` means smaller, `k`/`M`/`G` units)
- `-mmin 60` (modified in the last 60 minutes), `-mtime +60` (modified more than
  60 *days* ago)
- `-user NAME`, `-group NAME`
- `-perm 755` (exactly), `-perm -4000` (at least these bits — e.g. setuid)
- `\!` negates a test, `\( ... -o ... \)` groups with OR

### Acting on matches with -exec

```
find . -type f -exec chmod 664 {} \;
find . -type f -exec chmod 664 {} +
```

`{}` is replaced by the filename. `\;` runs the command once *per file*. `+`
batches many files into one command run — much faster. Use `+` when the command
can take many arguments (like `chmod`), `\;` when it can't.

`-execdir` runs the command from inside each file's own directory, which is
safer for renames.

## How to read the output

By default you get one matching path per line. With `-exec ... ls -la`, you get
`ls` output for each match. With `stat --format`, you get whatever fields you
asked for. Piping to `sort`, `head`, or `column -t` tidies big results.

## Common mistakes

- **Forgetting to quote `-name`.** `find . -name *.conf` lets the *shell* expand
  `*.conf` first and usually breaks. Always `-name '*.conf'`.
- **Putting the action before the tests.** `-delete` applies to whatever matched
  *before* it, so order matters.
- **Running `/` searches without `-xdev`** when you only meant one filesystem —
  you'll wander into `/proc`, network mounts, etc. `-xdev` stays on one device.
- **`find -delete` is irreversible.** There is no undo and no recycle bin.

## Job-relevant depth

### More tests you'll actually reach for
- `-newer FILE` / `-newermt '2026-10-01'` — changed more recently than a file,
  or than a date. Great for "what changed since the last good deploy?"
- `-empty` — empty files or directories (cleanup, or finding a truncated log).
- `-path '*/node_modules/*' -prune -o -type f -print` — `-prune` skips a whole
  subtree. The idiom: prune the thing, `-o` (OR), then the real action.
- `-regex` / `-iregex` — match the whole path with a regex, not just the name.
- `-maxdepth 1` / `-mindepth 2` — limit how deep you descend. `-maxdepth 1`
  makes `find` behave like a smarter `ls`. Put depth tests *first* for speed.
- `-printf '%s %p\n'` (GNU) — print custom fields (size, path, owner...) without
  spawning `stat` per file; much faster on big trees.

### -exec vs xargs — and why xargs usually wins
`-exec cmd {} +` already batches. But piping to `xargs` is more flexible and
composes with the rest of the shell:
```
find . -type f -name '*.log' -print0 | xargs -0 gzip      # compress all logs
find . -type f -print0 | xargs -0 -P4 -n100 md5sum        # 4 parallel workers
```
Always pair `find -print0` with `xargs -0` so filenames with **spaces or
newlines** don't get split into broken arguments. This is the single most common
real-world `find` bug.

## Reading tricky output

- `find: '/proc/...': Permission denied` on a `/` search is normal as a
  non-root user — add `2>/dev/null` to hide the noise, or run with sudo.
- `find: paths must precede expression` means you put a test *before* the
  starting path (e.g. `find -name x .`). Path first, then tests.
- Nothing printed = nothing matched. Loosen one test at a time to find out which
  filter is too strict.

## Common troubleshooting

- **"My `-delete` deleted a directory's contents too."** `-delete` implies
  `-depth`. Always dry-run the exact same filter with `-print` first.
- **"It's crawling into network mounts and `/proc`."** Add `-xdev` to stay on
  one filesystem, and `-prune` the trees you don't want.
- **"Spaces in names broke my pipe."** Switch to `-print0 | xargs -0`.

## Combine it

`find` is the front half of countless real one-liners:
```
# Disk hog hunt: biggest files under a tree, human sizes, top 10:
find /var -type f -printf '%s %p\n' 2>/dev/null | sort -nr | head | \
  awk '{ printf "%.1fMB  %s\n", $1/1048576, $2 }'

# Fix a web tree: files 644, dirs 755 (two safe, batched passes):
find /var/www -type f -exec chmod 644 {} +
find /var/www -type d -exec chmod 755 {} +

# Count files per extension across a project:
find . -type f -name '*.*' | sed 's/.*\.//' | sort | uniq -c | sort -nr
```
The pattern is always: `find` selects the files, a pipe (`xargs`, `awk`,
`sort | uniq -c`) does the counting/acting. Build it with `-print` first, swap
in the action only once the preview looks right.

## sudo / root?

Reading and searching your own files needs no root. Searching `/` fully, or
touching files you don't own (changing permissions, deleting system files),
needs sudo. The setuid-hunt (`-perm -4000` over `/`) is typically run as root so
it can see everything. Anything that writes, deletes, or chmods is a system
change — practice in a throwaway VM.
