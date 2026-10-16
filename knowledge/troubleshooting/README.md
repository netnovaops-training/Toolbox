# Troubleshooting log — problems I solved and what I learned

> **what:** a journal of real issues I hit, how I fixed them, and how I'm getting more prepared
> **status:** useful
> **tags:** troubleshooting, portfolio, outcomes, career
> **last-used:** 2026-10-15

This is my most useful folder for getting hired. Each entry is a real problem I ran
into, how I worked it out, and what I'll do differently next time. It turns "stuff I
struggled with" into **evidence I can troubleshoot** — the exact thing interviewers
want to hear (see `../notes/professional-git.md`).

## How to add an entry
1. Open a ticket (adds the dated entry on the `tickets` branch, already pushed):
   `bash code/local/newentry.sh troubleshooting short-title docker linux`
   (or `newentry.sh quick ...` for the short Issue / Fix / Learned form).
2. Fill in the XXX parts while it's fresh. Save progress any day with
   `bash code/local/worklog.sh "what I tried"`.
3. Keep it **generic and public-safe**: no secrets, no real IPs, no homelab
   specifics. Describe the *shape* of the problem, not my private setup.
4. When it's fixed: `bash code/local/resolve.sh`. Once `tickets` is merged into `main`
   it shows up in [LOGBOOK.md](../../LOGBOOK.md) by itself.

## Why this works for interviews
When they ask "tell me about a problem you solved," you open this folder and have
ten real ones ready — each framed as **problem → what I did → result → lesson**.
That's a candidate who learns, not just one who memorises.

## Issues → resolutions (the short collection)
One line each — scan it fast; click "full" for the write-up. Add a row when you add an entry.

| Date | Issue | Resolution | Tags | |
|------|-------|-----------|------|---|
| 2026-10-15 | Container couldn't write its mounted volume | Matched the container's UID to the host folder's owner | docker, permissions | [full](2026-10-15-container-volume-permission-denied.md) |
| | | | | |

_Keeping this table short and honest is the point — it's the quick view; the dated
files hold the detail; and the highlights roll up into [../../PORTFOLIO.md](../../PORTFOLIO.md)._
