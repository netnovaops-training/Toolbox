---
type: project
title: add branches to flow
date: 2026-10-15
branch: project/add-branches-to-flow
tech: [git, github]
status: in-progress
opened: 2026-10-15
closed:
tags: [pull-request, workflow, logbook]
summary: First real ticket - took a change from a branch to a pull request using the new logbook scripts, and fixed two problems found along the way.
lesson: Work goes on a branch and reaches main only through a reviewed pull request, so mistakes get caught before they land.
---

# add branches to flow

<!-- Project report. Fill in every placeholder. No secrets, keys, real IPs, or homelab details.
     Save progress:  bash code/local/worklog.sh "what I did"
     Close it:       bash code/local/resolve.sh -->

## Goal
- **What I'm building and why:** test code, gain understanding, and see how it works.
- **Done looks like:** having a stable work flow and understanding of what Git does and operates.

## Environment
- Git, Android, Web
- Termux on the phone, the GitHub website, and the Toolbox repo's logbook scripts

## Steps
1. Merged PR #2 (the logbook system) with a merge commit, then pulled `main` on the phone.
2. Opened this ticket with `bash code/local/newentry.sh project add-branches-to-flow git github`, which made the branch and the entry and pushed them.
3. Checked that `OPEN.md` listed the ticket by itself within a minute.
4. Opened PR #3 from the link in `OPEN.md`.
5. Wrote the PR description, found it rendered wrong, and fixed it.
6. Fixed the pull request template and the entry templates on this branch.

## Setup and where to find things
**Where my copies live**
- Phone (Termux): `~/learning-lab/Toolbox` - get there with `cd ~/learning-lab/Toolbox`
- PC: `D:\Toolbox` (also reachable from the phone over SSH in Termius)
- GitHub: https://github.com/netnovaops-training/Toolbox
- Always start with `git switch main && git pull` (or switch to the ticket branch and pull).

**Where to look on GitHub**
- `OPEN.md` - every ticket I've started and not finished, with links to the entry, branch and PR.
- `LOGBOOK.md` - every entry, sorted by date, status, type, topic, language and branch.
- `JACKET.md` - the lessons, grouped by technology.
- `GUIDE.md` (section 3) - the whole ticket flow; `knowledge/cheatsheets/my-commands.md` - the commands.
- Pull request tabs: **Conversation** = description and comments; **Files changed** = review only
  (tapping a line adds a review comment, it does not edit); **Checks** = the green ticks.

**How to do the common things**
- Edit a file on GitHub: open the file, then the pencil (or the file's menu in Files changed -> Edit file).
  Commit to the ticket branch, never to main.
- Edit in Termux: `nano <file>`, save with Ctrl+O then Enter, exit with Ctrl+X.
- Mark a PR as a draft: on the PR, under Reviewers, "Convert to draft".
- Delete a finished branch: Code -> Branches -> trash icon (or "Delete branch" after merging).
- Show code-like text without GitHub acting on it: wrap it in backticks, like `<!-- -->`.

**The ticket commands**
```
bash code/local/newentry.sh <type> <short-title> [tags ...]   # open
bash code/local/worklog.sh "what I did"                       # save progress
bash code/local/resolve.sh                                    # close, then merge the PR
```

## Issues hit
- **PR description text went missing** -> I typed my notes inside the hidden `<!-- -->` comments, and one comment wasn't closed, so GitHub hid most of the description. Fixed by pasting a clean description, and changed the PR template to visible `REPLACE` hints so it can't happen again.
- **Tried to fill the entry from the "Files changed" screen** -> tapping a line there opens a review comment, not an editor. To change a file, use the file's menu and choose "Edit file", or edit in Termux with `nano`.
- **`resolve.sh` would never have closed a ticket** -> the instruction comment in every template told me to fill every blank by naming the placeholder word itself, and the script counted that mention as an unfilled blank. Reworded the comment and made the script ignore text inside comments.

## Result (verified)
- **What works now:** the ticket flow runs from opening a ticket to an open pull request: branch made, entry pushed, listed in `OPEN.md`, linked to PR #3.
- **How I confirmed it:** `OPEN.md` showed the ticket with its branch and PR #3; the PR's checks are green. Merging this PR is the final step.

## What I learned
- A branch keeps unfinished work away from `main`; a pull request is where it gets checked before merging.
- Text inside `<!-- -->` never shows on GitHub, so never type answers inside one.
- The "Files changed" tab is for reviewing (comments), not editing.
- Testing with a fake shortcut can hide a real bug: my earlier test filled blanks with find-and-replace, which also changed the comment, so the `resolve.sh` bug only showed up on a real ticket.

## Work log
- 2026-10-15 - opened
- 2026-10-15 - opened PR #3; fixed the PR description and the PR template
- 2026-10-15 - filled in the write-up; fixed the resolve.sh placeholder bug
- 2026-10-15 - added setup notes and where to find things
