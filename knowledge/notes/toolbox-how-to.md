# How I build and grow this toolbox

# what: how to add to the toolbox and keep it tidy
# status: useful
# tags: git, workflow, notes
# last-used: 2026-10-15

One place for the scripts, commands and notes I want handy. Because it's a git
repo it's versioned (nothing lost), backed up on GitHub, and on every device.

## Reference vs toolbox
- A reference (like the book fork) is someone else's collection. I read it and
  copy useful bits out.
- This toolbox is mine. I put the useful bits in, in my own order.

## The loop I repeat
1. Make a file in the right folder, e.g. `dev/bash/backup-folder.sh`.
2. Put a short header on top (what / status / tags / last-used — see CONVENTIONS).
3. If I copied it from someone, add a row to `SOURCES.md` and keep their licence.
4. Save and commit:
   ```
   git add dev/bash/backup-folder.sh SOURCES.md
   git commit -m "Add a one-folder backup script"
   git push
   ```

Good commit messages say what in a few words ("Add a backup script"), not "update".

## On another device
After it's on GitHub:
```
git clone git@github.com:<me>/Toolbox.git
cd Toolbox
```
`git pull` to get what I added elsewhere; edit, commit, push to send changes back.

## Rules I keep
- One header at the top of every file: what it does.
- Copied something? Note it in SOURCES.md, keep its licence.
- **Never commit secrets** — keys, passwords, tokens. `.gitignore` blocks the
  common ones, but don't paste a secret into a file.
- This repo is **public** — only generic, reusable snippets. Real configs,
  addresses and anything personal stay in a private place.

## Quick git reminders
- `git status` — what changed
- `git add <file>` — stage it
- `git commit -m "message"` — save it
- `git push` / `git pull` — send / get
