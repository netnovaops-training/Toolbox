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

## sudo / root?

Reading and searching your own files needs no root. Searching `/` fully, or
touching files you don't own (changing permissions, deleting system files),
needs sudo. The setuid-hunt (`-perm -4000` over `/`) is typically run as root so
it can see everything. Anything that writes, deletes, or chmods is a system
change — practice in a throwaway VM.
