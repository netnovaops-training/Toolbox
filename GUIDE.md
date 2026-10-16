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
| `code/` | `mine/` = code I wrote · `useful/` = snippets I reuse · `local/` = automation tools. |
| `knowledge/` | Logbook entries: `troubleshooting/`, `installs/`, `projects/`, `learning/`. Plus `cheatsheets/`, `notes/`, `daily-log/`, `documents/`, `cert-prep/`. |
| `LOGBOOK.md` | Every logbook entry, sorted by date, status, type, language and branch. Built automatically. |
| `OPEN.md` | Live list of every open ticket (on any branch), each linked to its entry and pull request. Built automatically. |
| `JACKET.md` | My career jacket: every lesson learned, grouped by technology, linked to the work. Built automatically. |
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

## 3. The logbook (tickets)
Every piece of real work gets an entry, and every entry works like a ticket:
**two branches:**

- **`main`** - the finished, public version. Nothing is written to it directly.
- **`tickets`** - my working branch. Every ticket, fix and note goes here.

When I'm ready to publish, I open a pull request **`tickets` -> `main`** and merge it
(and keep the `tickets` branch - never click "Delete branch" on it). After the merge,
`LOGBOOK.md`, `JACKET.md` and my portfolio's Latest work rebuild themselves. The scripts
below always switch to `tickets` and bring in the latest from `main` for me.

**Pick the type:**
| Type | Use it for | Folder |
|---|---|---|
| `troubleshooting` | Something broke and I worked out why (full write-up) | `knowledge/troubleshooting/` |
| `quick` | A small fix: Issue / Fix / Learned | `knowledge/troubleshooting/` |
| `install` | Setting up or installing something new | `knowledge/installs/` |
| `project` | A bigger piece of work with steps and a goal | `knowledge/projects/` |
| `learning` | Something I studied | `knowledge/learning/` |

**The ticket flow:**
| Step | Command | What happens |
|---|---|---|
| Open | `bash code/local/newentry.sh <type> <short-title> [tech ...]` | Switches to `tickets`, makes the dated entry, pushes it. It shows in OPEN.md within a minute. |
| Edit | `nano <the entry>` (or edit on GitHub, on the `tickets` branch) | Fill in the XXX parts. |
| Save for the day | `bash code/local/worklog.sh "what I did"` | Saves my edits, adds a dated line to the Work log, status in-progress, pushes. Safe even if unfinished. If several tickets are open it asks which one (by number), or use `--file <part-of-name>`. |
| Come back later | just run the scripts again | They switch to `tickets` and pull the latest themselves. |
| Stuck | `bash code/local/worklog.sh --blocked "waiting on X"` | Status blocked. |
| Resolve | `bash code/local/resolve.sh` | Checks no XXX is left, sets resolved + closed date, pushes. |
| Publish | pull request `tickets` -> `main`, then **Create a merge commit** | Resolved tickets appear in LOGBOOK, JACKET and the portfolio. Keep the branch. |

**Show it off:** every project I resolve appears in the "Latest work" section of
[PORTFOLIO.md](PORTFOLIO.md) by itself (newest 5). For a fix or install worth showing,
change `showcase: false` to `showcase: true` at the top of the entry.

**See everything I have open:** [OPEN.md](OPEN.md) - rebuilt whenever I push to `tickets`
or a pull request opens, closes or merges. Click a ticket to open it.

**Hit a problem in the middle of a project?** Just open another ticket with
`newentry.sh troubleshooting ...` - it goes on `tickets` too, and both publish together.

**Smaller than a ticket:** a one-line note still goes straight in:
`bash code/local/note.sh "did a thing #tag"` -> `knowledge/daily-log/quick-notes.md`.
End-of-day recap: `knowledge/daily-log/_daily-template.md`.

**Tags (the words after the title):** any word works - `sso`, `authelia`, `ipv6`, `docker`,
`python`. Each becomes its own section in the logbook's **By topic** view and in the
career jacket. Programming languages (python, rust, bash, powershell, go, sql...) also
show up in **By language** on their own. One word per tag, dashes for two words
(`reverse-proxy`), keep the same spelling each time. A language it doesn't know? Add a
`lang: [zig]` line to the entry's top block. Example:
`bash code/local/newentry.sh install sso-setup authelia sso oidc`

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

## 7. My scripts (in `code/local/`)
**How to run one:** always `bash` + the full path + your arguments, from the repo root.
NOT bare `note.sh` (that errors "command not found"). `git pull` first so you have the latest.
```
bash code/local/note.sh "fixed the Caddy proxy #caddy #networking"   # quick tagged note -> commit -> push
bash code/local/newfix.sh container-permission-denied                # start a troubleshooting write-up
bash code/local/new-folders.sh                                       # make a batch of folders (edit the list first)
bash code/local/rename.sh code/old code/new                         # rename/move a file or folder, tracked + pushed
```
Windows (PowerShell) version of the folder maker:
```
powershell -ExecutionPolicy Bypass -File code/local/new-folders.ps1
```
Each script is listed in `code/local/README.md`.

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
