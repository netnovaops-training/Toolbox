#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Jason A. Gibson
# A safe, self-contained git walk-through. It creates a throwaway repo in a
# scratch dir, does the whole everyday loop PLUS the harder real-world moves
# (merge conflict, .gitignore, diff between commits, and safe undos), then
# cleans up after itself. Nothing here touches your real repos or the network.
# Run it, then read what it printed next to the comments.
set -euo pipefail                      # stop on error / unset var / failed pipe

work="$(mktemp -d)"                    # a private scratch folder
trap 'rm -rf "$work"' EXIT             # delete it when the script finishes
cd "$work"

echo "== 1. Start a repo =="
git init -q -b main                    # make this folder a git repo, default branch 'main'
git config user.name  "Test User"      # identity, local to this scratch repo only
git config user.email "test@example.com"
git config core.autocrlf false         # keep line endings as-is (quiets warnings)

echo "== 2. Make a file and SEE it as untracked =="
echo "hello" > notes.txt
git status -s                          # '??' means git isn't tracking it yet

echo "== 3. Stage it (add = move to the tray) =="
git add notes.txt
git status -s                          # 'A' means staged, ready to commit

echo "== 4. Commit (save a permanent snapshot) =="
git commit -q -m "Add notes.txt"
git log --oneline                      # one line per snapshot

echo "== 5. Change the file and SEE the difference =="
echo "second line" >> notes.txt
git diff                               # exactly what changed since the last commit
git add notes.txt
git commit -q -m "Add a second line"

echo "== 6. Branches are just labels =="
git switch -qc experiment              # make + switch to a new branch
echo "risky idea" >> notes.txt
git commit -qam "Try an idea on a branch"   # -a stages tracked files, -m message
git switch -q main                     # back to main — notes.txt has no 'risky idea' here
echo "   (on main, the experiment change isn't present)"

echo "== 7. Merge a branch that DOESN'T conflict =="
git merge -q experiment                # main had no new commits -> clean fast-forward
git log --oneline --graph              # the shape of the history

echo "== 8. Make a REAL merge conflict and resolve it calmly =="
echo "port=8080" > config.txt          # a fresh file both branches will fight over
git add config.txt
git commit -q -m "Add config.txt"
git switch -qc change-port             # branch that sets the port to 9090
echo "port=9090" > config.txt          # change the one line
git commit -qam "Change port to 9090"
git switch -q main                     # back on main, change the SAME line differently
echo "port=8081" > config.txt
git commit -qam "Change port to 8081"
# Both branches changed the same line -> git can't guess. The merge "fails" on
# purpose and leaves conflict markers in the file. '|| true' keeps our script
# going (a conflict is exit-code 1, which 'set -e' would otherwise treat as fatal):
git merge change-port -q || true
echo "   -- git stopped and marked the clash. 'both modified' below is the to-do list:"
git status -s                          # 'UU config.txt' = both modified, needs you
echo "   -- the file now contains <<<<<<< ======= >>>>>>> markers; here's the mess:"
cat config.txt
# Resolve: decide the final text and write it WITHOUT any marker lines.
# (Here we keep the branch's value. In real life you'd edit by hand.)
echo "port=9090" > config.txt
git add config.txt                     # 'add' means "I've settled this file"
git commit -q --no-edit                # finish the merge (git pre-filled the message)
echo "   -- resolved. (If you'd panicked, 'git merge --abort' undoes the whole thing.)"
git status -s                          # clean again — nothing to show

echo "== 9. .gitignore — tell git to ignore junk and secrets =="
printf '*.log\nsecret.env\n' > .gitignore   # patterns: all .log files, and secret.env
echo "debug output" > app.log          # would be noise in the repo
echo "TOKEN=do-not-commit" > secret.env     # a pretend secret — must never be committed
echo "   -- app.log and secret.env are IGNORED, so status only shows .gitignore:"
git status -s                          # neither ignored file appears here
git add .gitignore
git commit -q -m "Add .gitignore"

echo "== 10. Diff between two specific commits =="
older="$(git rev-parse --short HEAD~1)"   # grab the previous commit's short hash
newer="$(git rev-parse --short HEAD)"     # and the current one
echo "   -- comparing $older (older) to $newer (newer):"
git diff "$older" "$newer"             # '-' lines removed, '+' lines added

echo "== 11a. Undo: un-stage a file but KEEP your edits =="
echo "scratch" > temp.txt
git add temp.txt
git status -s                          # 'A temp.txt' = staged
git restore --staged temp.txt          # opposite of 'git add' — the edit stays, staging undone
git status -s                          # '?? temp.txt' = back to untracked, file intact
rm temp.txt                            # tidy up so it doesn't clutter later steps

echo "== 11b. Undo: uncommit the last commit, keeping changes staged (--soft) =="
echo "oops wrong message" >> notes.txt
git commit -qam "Bad commit message"
git reset --soft HEAD~1                # uncommit; the change is still STAGED, not lost
git status -s                          # 'M notes.txt' staged, ready to re-commit
git commit -q -m "Add a clarifying note to notes.txt"   # re-commit with a better message

echo "== 11c. Undo: revert — the SAFE undo for shared history =="
# 'revert' doesn't erase history; it adds a NEW commit that undoes an old one.
# This is what you use on main / anything already pushed (unlike reset --hard).
git revert --no-edit HEAD              # make a new commit that undoes the one above
git log --oneline                      # see the extra 'Revert ...' commit on top

echo "== 12. reflog — the safety net (every place HEAD has been) =="
git reflog -5                          # even after resets, old commits show here to recover

echo "== 13. What a remote WOULD look like (not run) =="
# On a real repo you'd connect to GitHub/Gitea and sync, then open a pull request:
#   git remote add origin git@github.com:you/repo.git   # name the remote 'origin'
#   git switch -c my-feature                             # work on a branch, never on main
#   git push -u origin my-feature                        # push the branch up
#   (open a Pull Request on the web UI; a teammate reviews; then it merges to main)
#   git pull                                             # later, get everyone's commits down
echo "   (remote + pull-request steps are comments only — no network used here)"

echo
echo "Done. This whole repo was in a scratch dir and is now deleted."
