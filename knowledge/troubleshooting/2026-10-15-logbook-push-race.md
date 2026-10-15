---
type: troubleshooting
title: logbook push race
date: 2026-10-15
branch: troubleshooting/logbook-push-race
tech: [github-actions, git]
status: in-progress
opened: 2026-10-15
closed:
tags: [ci, race-condition, workflow]
summary: After merging PR #3 the logbook rebuild failed to push because another job had updated main a moment earlier.
lesson: When two automated jobs can push to the same branch, each must pull the latest and retry, or the slower one gets rejected.
---

# logbook push race

<!-- Quick entry: fill in the placeholders. Save: bash code/local/worklog.sh "note"  Close: bash code/local/resolve.sh -->

**One line (for interviews):** A GitHub Actions job broke after a merge - I read the run log, found two jobs pushing to main at once, and added a pull-and-retry step so both now save cleanly.

- **Issue:** Merging PR #3 started two jobs at the same moment. The open-tickets job pushed OPEN.md first; the logbook job then tried to push on top of the old main and GitHub rejected it: `cannot lock ref 'refs/heads/main': is at 46fac91 but expected afc9327`. The pages were built correctly, they just couldn't be saved.
- **Fix:** Re-ran the logbook job by hand to update the pages straight away, then changed `.github/workflows/logbook.yml` so its commit step does `git pull --rebase` and retries the push up to three times - the same pattern the open-tickets job already used.
- **Learned:** Read the failed step's log before guessing; "rejected / expected X" means someone else pushed first, not that the work was wrong. Any job that pushes to a shared branch needs to pull and retry.

## Work log
- 2026-10-15 - opened
- 2026-10-15 - found the cause in the run log, re-ran the job, added pull-and-retry to the workflow
