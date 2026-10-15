> **what:** git — track changes to files, save versions, work across machines
> **status:** trying
> **tags:** git, version-control, foundational, sysadmin, dev
> **last-used:** 2026-10-15

# git — version control, the part that actually confuses people

Git isn't hard. It's confusing because nobody explains the **mental model** first —
they just throw commands at you. Learn the model and the commands stop feeling random.
On the job you'll touch git every single day, so the goal here isn't to memorise
commands — it's to build a picture in your head so clear that you can *reason* your
way out of trouble instead of pasting a scary command you found online.

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
Picture a photographer: the working folder is the messy room, the staging tray is
the stuff you've arranged in frame, and the commit is the photo. You can keep
rearranging the room, but only what's in frame lands in the picture.

### A commit is a snapshot with a name

Each commit stores: the full snapshot of your tracked files, **who** made it, **when**,
a **message**, and a pointer to the commit **before** it (its "parent"). That chain of
parents *is* your history. Each commit also has a long **hash** (like `a1b2c3d…`) — a
unique ID. You rarely type the whole thing; the first 7 characters are enough, and
`HEAD` almost always does the job instead.

### The pointers that move

- `HEAD` = a label meaning "where I am right now." Usually it points at a branch.
- `HEAD~1` = one commit back (the parent). `HEAD~2` = two back. Handy for "undo the
  last commit" — you'll see it below.

## Branches are just labels

A **branch** is a sticky note pointing at a commit. `main` is just a label.
When you commit, the label moves forward to the new commit. Making a branch is
cheap — it's one more sticky note. Switching branches changes which files you see.

Why teams live on branches: you build a feature on its own branch so `main` always
stays working. You, three teammates, and a bug-fix can all move in parallel without
stepping on each other. Then each branch gets reviewed and merged back in.

```
git switch -c add-login     # make a new branch and move onto it
git switch main             # hop back to main (instant — just moving the HEAD note)
git branch                  # list branches; the * is where you are
```
(Older tutorials use `git checkout -b` / `git checkout` for the same thing. `switch`
is the newer, clearer name — both still work.)

## Merging — bringing a branch back together

When your branch is done, you fold it into `main`:

```
git switch main             # be on the branch you're merging INTO
git merge add-login         # pull add-login's commits into main
```

Two things can happen:

- **Fast-forward:** if `main` hasn't moved since you branched, git just slides the
  `main` label forward. Clean, no new commit.
- **Merge commit:** if both branches have new commits, git combines them and makes
  one new "merge commit" with *two* parents. This is normal and fine.

### What a merge conflict actually is (don't panic)

A conflict happens when **both branches changed the same lines** of the same file,
and git can't know which version you want. Git is not broken and you didn't break it —
git is just refusing to guess. It stops and asks you.

Git marks the clash right inside the file, like this:

```
<<<<<<< HEAD
the version on the branch you're merging INTO (e.g. main)
=======
the version coming FROM the branch you're merging in
>>>>>>> add-login
```

**How to resolve one calmly** — it's always the same four moves:

1. `git status` — it literally lists the files "both modified." That's your to-do list.
2. Open each file. Decide what the final text should be: keep one side, keep the other,
   or blend them. **Delete all three marker lines** (`<<<<<<<`, `=======`, `>>>>>>>`).
3. `git add <file>` — this tells git "I've settled this one."
4. `git commit` — finishes the merge. (If you ran `git merge`, git pre-fills the message.)

If you get scared mid-conflict, `git merge --abort` puts everything back exactly as it
was before you started. You can always walk away. There is no way to get "stuck."

## `.gitignore` — files git should pretend it can't see

Some files should never be committed: secrets, passwords, build output, huge binaries,
editor junk, logs. You list patterns in a file named `.gitignore` at the repo root, and
git stops offering those files in `git status` / `git add .`.

```
# .gitignore  — one pattern per line
*.log            # any file ending in .log
.env             # local secrets / config — NEVER commit this
node_modules/    # a trailing slash means "this folder and everything in it"
build/           # generated output you can always rebuild
*.key            # private keys
!keep.log        # a leading ! un-ignores something an earlier line caught
```

Two things that trip people up:
- `.gitignore` only affects files git **isn't already tracking.** If you already
  committed `secrets.env` by accident, adding it to `.gitignore` does nothing — you
  must stop tracking it with `git rm --cached secrets.env` and commit that.
- A committed secret stays in history even after you delete the file. On the job this
  is a real incident: rotate the secret (change the password/key), don't just delete it.

## Viewing history — reading the story

This is a daily sysadmin skill: *something changed and broke; when, and by whom?*

```
git log                       # full history, newest first
git log --oneline             # one line per commit — the view you'll use most
git log --oneline --graph     # adds an ASCII picture of branches/merges
git log -5                    # just the last 5
git log --oneline -- file.txt # only commits that touched file.txt
```

Look at a single commit in detail:
```
git show <hash>               # the message + the exact changes that commit made
git show HEAD                 # the most recent commit
```

Compare any two points — this is how you answer "what changed between these?":
```
git diff                      # working folder vs staging (unstaged edits)
git diff --staged             # staging vs last commit (what your next commit will save)
git diff HEAD~1 HEAD          # the previous commit vs the current one
git diff <hashA> <hashB>      # any two commits, by hash
git diff main add-login       # how two branches differ
```
Reading a diff: lines starting `-` were removed, lines starting `+` were added. The
`@@ ... @@` header tells you which line numbers you're looking at.

## Undoing things safely

Most "I lost my work" moments are recoverable. The trick is knowing which tool matches
which mistake — and that the gentle ones are far more common than the scary ones.

**Throw away un-committed edits to a file** (go back to the last commit's version):
```
git restore file.txt          # discards unstaged edits to that file (can't undo this)
```

**Un-stage** (take out of the tray, but keep your edits):
```
git restore --staged file.txt # the opposite of git add; your edits stay in the folder
```

**Undo the last commit**, three flavours — the difference is *what happens to the changes*:
```
git reset --soft HEAD~1    # uncommit, keep changes STAGED (fix the message / re-commit)
git reset --mixed HEAD~1   # uncommit, keep changes in the folder but UNstaged (the default)
git reset --hard HEAD~1    # uncommit AND delete the changes  <-- destructive, be sure
```
Think of it as a dial from gentle to nuclear: `--soft` barely moves anything, `--mixed`
unstages, `--hard` throws the work away. Use `--hard` only when you truly want the work
gone, and never on commits you've already pushed and shared.

**`git revert` — the safe undo for shared history:**
```
git revert <hash>          # makes a NEW commit that undoes an old one
```
`reset` rewrites history (dangerous once others have your commits). `revert` adds a new
commit on top, leaving history intact — this is what you use on `main` and anything
you've already pushed. Rule of thumb: **reset for private/local, revert for shared.**

**`git reflog` — the safety net that saves you:**
```
git reflog                 # every place HEAD has been, even after a reset
```
Even after a `reset --hard`, the old commit usually still exists; `reflog` shows its
hash so you can `git switch -c rescue <hash>` and get it back. Knowing reflog exists is
what lets you stay calm. "I deleted my work" is almost always "I can't currently see my
work."

## Remotes & the pull-request workflow (the real team loop)

`origin` is the usual name for the remote copy (your repo on GitHub / Gitea).
- `git push` = send my new commits **up** to origin.
- `git pull` = bring origin's new commits **down** to me (it's `fetch` + `merge` in one).
- `git fetch` = download their commits but **don't** merge yet (look before you leap).
- `git clone <url>` = make a local copy of a remote repo for the first time.

Your PC copy and, say, a phone copy each have their own history; push/pull keep them in
sync through origin.

**The pull-request (PR) workflow — how professional teams actually ship.** You almost
never commit straight to `main`. Instead:

1. `git switch -c fix-typo` — branch off `main` for one focused change.
2. Make commits on that branch.
3. `git push -u origin fix-typo` — push the branch up (the `-u` links it so later you
   can just type `git push`).
4. On GitHub/Gitea, open a **pull request**: "please merge my branch into main."
5. A teammate **reviews** it, comments, maybe asks for changes. You push more commits to
   the same branch; the PR updates automatically.
6. When approved, it's merged into `main`, and the branch is deleted.

Why employers care: the PR is where **review, discussion, and a paper trail** happen.
It's how teams keep `main` always-working and catch mistakes before they ship. Being
comfortable here is half of "can this person work on a team?"

## Good commit-message habits

A commit message is you explaining to a future stranger (often future-you) *why* this
change exists. Interviewers and teammates read these.

- **Short summary line**, ~50 chars, in the **imperative**: "Add login retry," not
  "added" or "adding." Trick: it should finish the sentence "If applied, this commit
  will ___."
- **Blank line, then a body** (for anything non-trivial) explaining *why*, not *what* —
  the diff already shows what.
- **One logical change per commit.** Don't mix a bug fix with a rename with a new
  feature. Small commits are easy to review and easy to revert.
- Bad: `update`, `stuff`, `fixes`, `asdf`. Good: `Fix crash when config file is missing`.

```
Fix crash when config file is missing

The parser assumed config.json always existed and threw on startup.
Fall back to built-in defaults and log a warning instead.
```

## Why it matters on the job

Every team uses git. Employers expect you to: make small, clear commits with good
messages; work on a branch and open a pull request (not commit straight to `main`);
read a `git log` / `git diff` to investigate when something broke; resolve a merge
conflict without panicking; and recover safely when something goes wrong. Your commit
history here is literally a record of your growth — recruiters can see it.

## Common confusions, cleared up

- **"add" doesn't send anything anywhere.** It only stages, locally. `push` sends.
- **A commit is local** until you `push`. You can commit on a plane.
- **Branches don't copy the whole project.** They're labels; switching is instant.
- **`git pull` = fetch + merge.** It downloads *and* combines in one step.
- **A merge conflict isn't an error.** It's git asking you to choose. `--abort` always
  backs out.
- **`reset` vs `revert`:** reset rewrites history (local only); revert adds a new
  undo-commit (safe for shared/pushed work).
- **Detached HEAD / "I lost my work"** — usually it's still there; `git reflog`
  shows where you've been. Ask before running anything with `--force` or `reset --hard`.

## Where to go deeper

- Official Pro Git book (free): https://git-scm.com/book/en/v2
- Resolving a conflict, step by step: https://git-scm.com/book/en/v2/Git-Branching-Basic-Branching-and-Merging
- `git reset` demystified (the three flavours): https://git-scm.com/book/en/v2/Git-Tools-Reset-Demystified
- Your `knowledge/cheatsheets/git-cheatsheet.md` — quick command reference.
- Your `knowledge/notes/github-pr-workflow.md` — the safe branch→PR→merge route.
