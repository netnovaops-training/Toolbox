#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2026 Jason A. Gibson
# A safe, self-contained git walk-through. It creates a throwaway repo in a
# scratch dir, does the whole everyday loop, and cleans up after itself.
# Nothing here touches your real repos. Run it, then read what it printed.
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
git switch -c experiment               # make + switch to a new branch
echo "risky idea" >> notes.txt
git commit -qam "Try an idea on a branch"   # -a stages tracked files, -m message
git switch -q main                     # back to main — notes.txt has no 'risky idea' here
echo "   (on main, the experiment change isn't present)"

echo "== 7. Merge the branch into main =="
git merge -q experiment                # bring the experiment's commits into main
git log --oneline --graph              # the shape of the history

echo "== 8. What a remote WOULD look like (not run) =="
# On a real repo you'd connect to GitHub and sync:
#   git remote add origin git@github.com:you/repo.git   # name the remote 'origin'
#   git push -u origin main                              # send commits up
#   git pull                                             # get commits down
echo "   (remote steps are shown as comments — no network used here)"

echo
echo "Done. This whole repo was in a scratch dir and is now deleted."
