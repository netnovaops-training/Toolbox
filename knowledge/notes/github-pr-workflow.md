# GitHub: the safe pull-request workflow

# what: how I ship changes safely through branches and PRs
# status: useful
# tags: github, git, pull-request, ci, security
# last-used: 2026-10-15

Generic notes (no project specifics here).

## The one rule
If anything (or anyone) installs from `main`, then `main` must stay clean.
So: **never commit straight to `main`.** Put changes on a side branch, open a
pull request, let the checks go green, then merge. The merge is the only way
code reaches `main`.

Typical branches:
- **main** — the released line. Only reviewed, green changes land here.
- **fixes** — fixes for broken things gather here first.
- **enhancements** — new features gather here first.

If a screen says "Commit directly to the main branch", choose **Create a new
branch** instead.

## Words I'll see
- **Branch** — a separate copy of the code I can change without touching main.
- **Commit** — one saved change, with a message.
- **Pull request (PR)** — a request to merge one branch into another; shows the
  diff, runs the checks, has a Merge button.
- **Checks** — the automatic tests on a PR. Green = passed.
- **Merge** — copy the branch's changes into the target branch.

## The bots (all go through a PR I approve)
- **CodeQL** — reads code for security bugs; alerts go to the Security tab.
- **Copilot Autofix** — drafts a fix and opens a PR. It's a draft — read it,
  never merge blind.
- **Dependabot** — opens PRs to update old or vulnerable libraries.
- **Clippy / detekt / Semgrep / Trivy / Bandit** — extra checkers; findings in
  the Security tab.

## The safe route
1. Open the PR; the top line must say which branch it merges into.
2. Wait for the checks to go green.
3. Unsure about a Dependabot/Autofix PR? Test it on a side branch first.
4. Green and safe → Merge, then Confirm. Plain merge (not squash/rebase) unless
   there's a reason.
5. Only delete throwaway branches, never the long-lived ones.

## Dependabot
- **Security updates** (known hole): do soon.
- **Version updates** (just newer): no rush; big jumps can break the build, so
  test those first. A small patch bump is usually safe.

## Security tab: real vs false
Not every alert is real — a scanner can flag safe code it doesn't understand
(false positive). Dismiss false positives **with a reason** so they don't
return. A real one names a clear risk (user input reaching a file or URL, weak
crypto); a false one is often "this *might* be user input" when it isn't.
