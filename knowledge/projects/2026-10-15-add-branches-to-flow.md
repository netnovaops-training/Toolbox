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

## Issues hit
- **PR description text went missing** -> I typed my notes inside the hidden `<!-- -->` comments, and one comment wasn't closed, so GitHub hid most of the description. Fixed by pasting a clean description, and changed the PR template to visible `REPLACE` hints so it can't happen again.
- **Tried to fill the entry from the "Files changed" screen** -> tapping a line there opens a review comment, not an editor. To change a file, use the file's menu and choose "Edit file", or edit in Termux with `nano`.
- **`resolve.sh` would never have closed a ticket** -> the instruction comment in every template said "Fill every XXX", and the script counted that as an unfilled blank. Reworded the comment and made the script ignore text inside comments.

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
