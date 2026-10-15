# My commands — all the automations in one place

> **what:** every copy-paste command for my toolbox, so I can grab them on the go
> **status:** useful
> **tags:** commands, automation, git, cheatsheet
> **last-used:** 2026-10-15

Scripts live in `code/local/`. Notes/docs are `.md` (renders nicely, searchable);
runnable things are `.sh`. Run scripts from anywhere in the repo.

## Logbook tickets
```
bash code/local/newentry.sh <type> <short-title> [tech ...]   # open: branch + entry + push
bash code/local/worklog.sh "what I did"                       # save progress (in-progress)
bash code/local/worklog.sh --blocked "waiting on X"           # parked
bash code/local/resolve.sh                                    # close it, then merge the PR
git switch <type>/<short-title> && git pull                   # come back to a ticket
```
Everything open, clickable: `OPEN.md` at the repo root.
Types: troubleshooting, quick, install, project, learning. Example:
```
bash code/local/newentry.sh project add-branches-to-flow git github
```

## Quick note (one line, tagged)
Easiest (runs the script — pulls, appends, commits, pushes):
```
bash code/local/note.sh "fixed the Caddy proxy #caddy #networking"
```
By hand:
```
git pull && echo "$(date +%F) - did a thing #tag" >> knowledge/daily-log/quick-notes.md && git commit -am "note" && git push
```

## New troubleshooting write-up
Start one (makes a dated file from the template):
```
bash code/local/newfix.sh container-permission-denied
```
Then open the file, fill the XXX, and save it:
```
git add knowledge/troubleshooting/ && git commit -m "Troubleshooting: <title>" && git push
```

## New folders (bulk)
Edit the list inside, then run:
```
bash code/local/new-folders.sh            # Linux / Termux
powershell -ExecutionPolicy Bypass -File code/local/new-folders.ps1   # Windows
```

## The everyday git loop
```
git pull                 # get current
git status               # what changed
git diff                 # read your change
git add <files>          # stage (no secrets!)
git commit -m "what"     # save (spell-check runs here)
git push                 # send to GitHub
```

## Fix / recover
```
git restore <file>             # undo edits to a file
git pull                       # get a deleted file back
git commit --no-verify         # commit past the spell-check on purpose
git config core.hooksPath .githooks   # turn on the local spell-check (once per clone)
```

## Find a tag
Open `TAGS.md` and click a tag, or type the `#tag` in GitHub's search box.
