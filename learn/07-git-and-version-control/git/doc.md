> **what:** git — track changes to files, save versions, work across machines
> **status:** trying
> **tags:** git, version-control, foundational, sysadmin, dev
> **last-used:** 2026-10-15

# git — version control, the part that actually confuses people

Git isn't hard. It's confusing because nobody explains the **mental model** first —
they just throw commands at you. Learn the model and the commands stop feeling random.

## The mental model (read this twice)

Git has **three places** a file can be:

1. **Working folder** — the files you actually edit. What you see in the folder.
2. **Staging area** (the "index") — a holding tray. You put the changes you want
   in your next save here.
3. **History** (commits) — permanent saved snapshots.

A change moves: **edit → stage → commit**.
- `git add` moves a change from the working folder into the staging tray.
- `git commit` takes everything in the tray and makes one permanent snapshot.

That two-step (stage, then commit) is the thing that confuses beginners. It exists
so you can choose *exactly* what goes into each save, instead of all-or-nothing.

## Branches are just labels

A **branch** is a sticky note pointing at a commit. `main` is just a label.
When you commit, the label moves forward to the new commit. Making a branch is
cheap — it's one more sticky note. Switching branches changes which files you see.

`HEAD` is a label meaning "where I am right now."

## Remote = a copy somewhere else (like GitHub)

`origin` is the usual name for the remote copy (your repo on GitHub).
- `git push` = send my new commits **up** to origin.
- `git pull` = bring origin's new commits **down** to me.

Your PC copy and your phone copy each have their own history; push/pull keep them
in sync through origin. (That's why the D: copy and a Termux copy stay matched.)

## The everyday loop (this is 90% of git)

```
git status            # what changed, what's staged — run this constantly
git add <file>        # stage a change (git add .  stages everything)
git commit -m "msg"   # save a snapshot with a message
git push              # send it to GitHub
git pull              # get the latest from GitHub
```

## Why it matters on the job

Every team uses git. Employers expect you to: make small, clear commits with good
messages; work on a branch and open a pull request (not commit straight to `main`);
read a `git log` / `git diff`; and recover when something goes wrong. Your commit
history here is literally a record of your growth — recruiters can see it.

## Common confusions, cleared up

- **"add" doesn't send anything anywhere.** It only stages, locally. `push` sends.
- **A commit is local** until you `push`. You can commit on a plane.
- **Branches don't copy the whole project.** They're labels; switching is instant.
- **`git pull` = fetch + merge.** It downloads *and* combines in one step.
- **Detached HEAD / "I lost my work"** — usually it's still there; `git reflog`
  shows where you've been. Ask before running anything with `--force` or `reset --hard`.

## Where to go deeper

- Official Pro Git book (free): https://git-scm.com/book/en/v2
- Your `knowledge/cheatsheets/git-cheatsheet.md` — quick command reference.
- Your `knowledge/notes/github-pr-workflow.md` — the safe branch→PR→merge route.
