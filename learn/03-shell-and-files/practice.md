# what: practice exercises for lesson 01 — shell/terminal, find, lsof
# status: trying
# tags: linux, practice, shell, find, lsof
# last-used: 2026-10-15

# Practice — Shell & Files

Do these in a throwaway VM or container. Build your own scratch files first
(`mktemp -d`, then create a few files/dirs) so nothing real is at risk. These
are hints, not full answers — reach for `man <tool>` and the `doc.md` in each
subfolder when you get stuck.

## Easy

1. **Capture and split output.** Run any command that prints both normal text
   and an error. Save normal output to `out.log` and errors to `err.log`, then
   view each.
   - Hint: two redirections on one line — one for stream 1, one for stream 2.

2. **Back up before you break it.** Make a file `app.conf`, then create
   `app.conf.orig` in a single short command.
   - Hint: brace expansion — `{,.orig}`.

3. **Find the recent changes.** Create a couple of files, then list every file
   under the current directory modified in the last 60 minutes.
   - Hint: `find`, `-mmin`, and remember the minus sign means "within".

## Medium

4. **Hunt the big files.** Make a file of a few MB (e.g. with `head -c`), then
   find every file larger than 1 MB under your scratch tree.
   - Hint: `-size +1M`, and narrow to `-type f` so directories don't clutter it.

5. **Preview before you delete.** Find files older than 30 days and *print*
   them. Explain to yourself what you would change to actually delete them —
   but don't run the delete.
   - Hint: `-mtime +30 -print`. The destructive swap is a single word.

6. **Who's on that port?** Start something that listens (or just inspect the
   system), then find which process owns a given TCP port.
   - Hint: `lsof -i tcp:<port>`, add `-P -n` to keep it fast and literal.

7. **Fix a web directory's permissions.** On a scratch copy of a `site/` tree,
   set all *files* to 644 and all *directories* to 755 — in two commands.
   - Hint: two `find` runs, each with `-type` and `-exec chmod ... {} +`.

## Harder

8. **List every listening socket with its program.** Produce a clean, aligned
   list of everything listening, showing the command behind each.
   - Hint: `lsof -i -P -n`, filter for `LISTEN`, tidy with `column -t`. Think
     about why you'd want `sudo` here.

9. **Newest files first.** Across a tree, list files sorted by modification
   time, newest at the top, showing the human-readable timestamp.
   - Hint: `find ... -exec stat --format ...`, then `sort -nr`, then trim the
     sort key with `cut`.

10. **Audit for setuid.** Search a tree for setuid or setgid executables and
    show full `ls -l` detail for each. Why does a security reviewer care about
    these?
    - Hint: group two `-perm` tests with `\( ... -o ... \)`; the setuid bit is
      `-4000`, setgid is `-2000`.
