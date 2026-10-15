# Professional-ready git — what employers actually look for

> **what:** how to use git so hiring managers see a qualified engineer
> **status:** useful
> **tags:** git, career, portfolio, professional
> **last-used:** 2026-10-15

Employers don't grade your git on fancy commands. They look at a few signals that
say "this person can work on a team without breaking things." Here they are, and
how I hit each one.

## What they want to see

1. **Small, focused commits.** One change per commit, not a giant "did a bunch of
   stuff." Shows you can reason about change in pieces.
2. **Clear commit messages that say *what* and *why*.** `Add retry to upload so a
   dropped connection doesn't lose the file` beats `fix`.
3. **Branches + pull requests, not commits straight to `main`.** Shows you know
   how teams protect shared code and review each other.
4. **Green checks.** Tests/linters/scanners passing on your PRs. Shows you ship
   working code, not "works on my machine."
5. **A readable history.** Someone can skim `git log` and understand how the
   project grew. That's you, documented.
6. **No secrets, ever, in the history.** A leaked key in a repo is an instant red
   flag. You scan before you commit.

## How I show it (map to my habits)

- I follow the [always-do checklist](always-do-checklist.md) — pull, branch, diff,
  no secrets, clear message, push, check green.
- My commits are authored as me, so my history is honestly mine.
- I use the [safe PR workflow](github-pr-workflow.md) on real projects.
- Spell-check and other checks run on every push, so my repos stay green.

## Talk about OUTCOMES, not commands

In a resume, cover letter, or interview, don't say "I know git / bash / nmap."
Say what you *achieved* with them. Frame it: **problem → what I did → result.**

- ❌ "Used tcpdump and dig."
- ✅ "Traced why a service was unreachable — captured traffic with tcpdump, found
   DNS was resolving to the wrong host, fixed the record, and connections recovered."

- ❌ "Know Linux permissions."
- ✅ "Fixed a container that couldn't write to its volume by matching the
   container's user to the host folder's owner — the app came back up."

- ❌ "Set up a homelab."
- ✅ "Run a multi-service homelab (reverse proxy, containers, DNS, backups) that I
   use to practice the exact problems a junior admin hits — and I document the fixes."

## Proving the professional fit (what to lead with)

When they ask about fit, lead with the things they're hiring for, backed by a real
example from my own work:

- **Troubleshooting** — "Here's a problem I hit and how I worked it out." (My
  strongest card — real fixes beat memorized facts.)
- **Does it safely** — I test in a VM, I don't guess on production, I keep backups.
- **Communicates** — I write down what I did so the next person (or me) can follow.
- **Keeps learning** — point to this repo: a visible, dated record of growth.
- **Security-aware** — Security+ plus habits: no secrets in git, least privilege,
  authorization before scanning.

## One-liner to remember

**Employers hire outcomes and judgment, not command lists. Git is where they see
how I work — so I keep it small, clear, green, and honest.**
