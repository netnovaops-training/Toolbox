# How my Toolbox works — full walkthrough

Everything in this repo and how to use it. Written 2026-10-15.

## Where it lives
- **PC:** `D:\Toolbox`
- **GitHub:** https://github.com/netnovaops-training/Toolbox
- **Phone (Termux):** `~/learning-lab/Toolbox`
- Front page is `README.md`, which links to `PORTFOLIO.md`.
- All three copies stay in sync through GitHub: `git pull` to get the latest, `git push` to send yours.

## The map
| Folder / file | What it's for |
|---|---|
| `learn/` | The lessons, in order (start at `learn/START-HERE.md`). |
| `code/` | `mine/` = code I wrote · `useful/` = snippets I reuse. |
| `knowledge/` | `cheatsheets/`, `notes/`, `troubleshooting/`, `daily-log/`, `documents/`, `cert-prep/`. |
| `infra/` | Notes by ops topic (networking, etc.). |
| `PORTFOLIO.md` | My professional page, browsable by skill. |
| `TAGS.md` | Click a tag to see every note with it. |
| `SKILLS.md` | The big skills roadmap. |
| `GUIDE.md` | This file. |

---

## 1. Learn (the lessons)
- Open **`learn/START-HERE.md`** — the path: networking → CLI → systems → security, plus git (foundational) and permissions.
- Each lesson folder has one subfolder per tool; each tool has **`doc.md`** (understand it) + **`examples.sh`** (real commands to run), and a **`practice.md`** per lesson.
- Run examples in a **throwaway VM/container**, not a live box.

## 2. My code
- **`code/mine/`** — scripts I wrote. **`code/useful/`** — stuff I copied and reuse (credit it in `SOURCES.md`).

## 3. Notes & capture (fast → full)
Pick the size that fits:
- **Quick note (fastest):** add one tagged line to **`knowledge/daily-log/quick-notes.md`**.
- **Small fix:** copy **`knowledge/troubleshooting/_quick.md`** (Issue / Fix / Learned).
- **Full write-up:** copy **`knowledge/troubleshooting/_template.md`**.
- **End of day:** copy **`knowledge/daily-log/_daily-template.md`**.
- Short scannable list of fixes: the table in **`knowledge/troubleshooting/README.md`**.

## 4. Tags
- Type `#tag` right in any note (e.g. `#networking #junsgarden`).
- **`TAGS.md`** — every tag is a clickable live search; click it to see all notes with it. Or type the `#tag` in GitHub's search box. New tags work automatically.

## 5. Get-hired tools
- **`PORTFOLIO.md`** — skill menu at top (Networking, Linux, Containers…); each links to proof. Shows "Recent progress" over time.
- **`knowledge/notes/hiring-scorecard.md`** — what employers want, ticked off as I hit it.
- **`knowledge/notes/professional-git.md`** — how to talk in outcomes, not command lists.
- **`knowledge/notes/always-do-checklist.md`** — the habits to do every time.

## 6. Cheat sheets & reference
- **`knowledge/cheatsheets/`** — linux, powershell, git, and `fork-quick-reference.md` (the tools I didn't make lessons for).
- **`knowledge/documents/reference.md`** — links into the big book chapters.
- **`knowledge/notes/using-md-files-in-git.md`** — how markdown-in-git works.

## 7. Make folders fast
- **`code/mine/new-folders.sh`** / **`new-folders.ps1`** — edit the list, run it, it makes folders and keeps them in git.

## 8. The git flow (every time)
```
git pull                         # get current
# ...make your change...
git status                       # see what changed
git diff                         # read your change
git add <files>                  # stage (no secrets!)
git commit -m "what I did"       # save
git push                         # send to GitHub (cements it)
```
A spell-check runs on push; if a check goes **red** it names a typo — fix and push again.

## 9. Recover anything (nothing is ever lost)
```
git restore <file>               # undo edits to a file
git pull                         # get a deleted file back from GitHub
git reflog                       # find where you were, to recover a commit
```

---

## Copy-paste shortcuts
```
# quick tagged note:
echo "$(date +%F) — did a thing  #tag" >> knowledge/daily-log/quick-notes.md && git commit -am "note" && git push

# new troubleshooting write-up:
cp knowledge/troubleshooting/_quick.md "knowledge/troubleshooting/$(date +%F)-short-title.md"
# fill it, then:
git add knowledge/troubleshooting/ && git commit -m "Troubleshooting: short-title" && git push
```
