---
type: troubleshooting
title: leftover merge conflict
date: 2026-10-16
branch: tickets
tech: [github-actions, git]
status: resolved
opened: 2026-10-16
closed: 2026-10-16
tags: [merge-conflict, ci, workflow]
showcase: false
summary: A merge conflict resolved in the GitHub web editor kept both versions of a workflow step, so the portfolio's Latest work was never saved.
lesson: When resolving a merge conflict, pick or combine the two sides into one - keeping both one after the other leaves dead code that silently does the wrong thing.
---

# leftover merge conflict

<!-- Quick entry: fill in the placeholders. Save: bash code/local/worklog.sh "note"  Close: bash code/local/resolve.sh -->

**One line (for interviews):** A workflow quietly stopped saving part of my site - I traced it to a merge conflict where both versions of a step were kept, merged them into one, and the step works again.

- **Issue:** PR #4 (push retry) and PR #5 (portfolio Latest work) both changed the "Commit if changed" step in `.github/workflows/logbook.yml`. When I resolved the conflict on GitHub, both versions stayed in the file, one after the other. The first one ends with `exit`, so the second (the one that saves `PORTFOLIO.md`) never ran - no error, it just didn't happen.
- **Fix:** Rewrote the step as one block that does both: saves `LOGBOOK.md`, `JACKET.md` and `PORTFOLIO.md`, and pulls + retries if another job pushed first. Checked it with actionlint.
- **Learned:** A conflict shows two versions between `<<<<<<<`, `=======` and `>>>>>>>`. The job is to end up with *one* correct version, not both. After resolving, read the whole section once more and ask "does this still make sense top to bottom?"

## Work log
- 2026-10-16 - opened
- 2026-10-16 - found both versions in logbook.yml, combined them into one step
- 2026-10-16 - fixed in logbook.yml
