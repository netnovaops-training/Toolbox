# Scripts — my automation tools

> **what:** the little scripts that automate my repo chores
> **status:** useful
> **tags:** scripts, automation, tools
> **last-used:** 2026-10-15

Run these from anywhere inside the repo. Full reference:
[../../knowledge/cheatsheets/my-commands.md](../../knowledge/cheatsheets/my-commands.md).

## Logbook tickets
| Script | What it does |
|---|---|
| `bash code/local/newentry.sh <type> <short-title> [tech ...]` | Open a ticket: makes a branch, a dated entry from the right template, pushes it. Types: troubleshooting, quick, install, project, learning. |
| `bash code/local/worklog.sh "what I did"` | Save progress on the current ticket: dated work-log line, status in-progress, push. Add `--blocked` if stuck. |
| `bash code/local/resolve.sh` | Close the ticket: status resolved, closed date, push. Then merge the pull request. |
| `bash code/local/newfix.sh <short-title> [tech ...]` | Shortcut for `newentry.sh quick ...`. |
| `python -I code/local/build_open.py` | (Optional, PC, after `git fetch`) preview OPEN.md. GitHub rebuilds it on every ticket push or PR change. |
| `python -I code/local/build_index.py` | (Optional, PC) preview LOGBOOK.md and JACKET.md. GitHub rebuilds them on every merge anyway. |

## Everyday chores
| Script | What it does |
|---|---|
| `bash code/local/note.sh "text #tag"` | Add a one-line tagged note, commit + push in one go. |
| `bash code/local/new-folders.sh` / `code/local/new-folders.ps1` | Make a batch of folders (edit the list inside first). |
| `bash code/local/rename.sh <old> <new>` | Rename/move a file or folder (git-tracked), commit + push. |
| `code/local/make-folders.ps1` | Older folder-maker (kept for reference). |

`_entry-lib.sh` holds helpers shared by the ticket scripts; you don't run it directly.
