# Learning log

Newest first. One short entry per thing I learn: what I did, what I learned,
what tripped me up.

## 2026-10-14
- Set up GitHub code scanning (CodeQL) and read real alerts for the first time.
- Learned the safe route: never commit to `main`; use a branch and a pull
  request; let the checks go green; merge with a plain merge (not squash).
- Learned that a scanner alert can be a false positive, and how to dismiss one
  with a reason so it does not come back.
- Learned what Dependabot, Copilot Autofix and the fingerprint bot each do.
- Tried: creating a fine-grained GitHub token (read-only, one repo, short life).
- Still fuzzy on: when a big version bump is safe to merge. Plan: test on a side
  branch first and read the library's changelog.
