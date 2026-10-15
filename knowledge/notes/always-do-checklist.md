# Always-do checklist — the habits that keep me safe and look professional

> **what:** the specific things I do every time I work in a repo
> **status:** useful
> **tags:** workflow, git, habits, safety
> **last-used:** 2026-10-15

Short list. If I do these every time, I can't really break anything, and my work
looks like a professional's.

## Before I change anything
- [ ] `git status` — see what's already changed, know where I stand.
- [ ] `git pull` — get the latest so I'm not editing an old copy.
- [ ] If it's a real/shared project: work on a **branch**, not `main`
      (`git switch -c my-change`).

## While I work
- [ ] Put a **header** on any new file (what / status / tags / last-used — see CONVENTIONS.md).
- [ ] Run anything risky in a **throwaway VM or container**, never on a live box.
- [ ] Copied code from someone? Add a row to `SOURCES.md` and keep its licence.

## Before I commit
- [ ] Re-read my change: `git diff`.
- [ ] **No secrets** — no passwords, keys, tokens, real IPs, or homelab details.
      This repo is **public**.
- [ ] Stage only what I mean to: `git add <files>` (not blind `git add .` if unsure).

## Commit and send
- [ ] Clear message saying *what*: `git commit -m "Add backup script"` — not "update".
- [ ] `git push`.
- [ ] Check the repo's **Actions** tab is green (spell-check, etc.).

## If something looks broken (I can always recover)
- Un-stage a file: `git restore --staged <file>`
- Throw away edits to a file (careful): `git restore <file>`
- See where I've been: `git reflog`
- Undo the last commit but keep my edits: `git reset --soft HEAD~1`
- **When in doubt, don't force anything** — ask my mentor before `reset --hard`,
  `push --force`, or deleting a branch.

## The one-line version
**Pull → branch → work → diff → no secrets → commit with a message → push → check green.**
