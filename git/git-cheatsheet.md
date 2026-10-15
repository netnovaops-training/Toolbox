# Git cheatsheet — the commands I use

A quick reference. Written by me from real use.

## Daily
- `git status`            — what has changed
- `git add <file>`        — stage a change
- `git commit -m "msg"`   — save staged changes with a message
- `git push`              — send commits to GitHub
- `git pull`              — get the latest from GitHub

## Branches (the safe route)
- `git switch -c fixes`   — make and move to a new branch
- `git switch main`       — move back to main
- never commit straight to main; use a branch + pull request

## Looking around
- `git log --oneline`     — short history
- `git diff`              — what changed, line by line

## Tags (version markers)
- `git tag -a v1.0 -m "first release"`  — annotated tag on this commit
- `git push origin v1.0`                 — send the tag
- tags stay put; branches move
