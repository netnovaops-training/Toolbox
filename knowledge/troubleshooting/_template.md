<!-- ============================================================
     HOW TO USE THIS TEMPLATE  (delete this whole block when done)

     1. Copy me to a dated file (this fills today's date for you):
          cp knowledge/troubleshooting/_template.md "knowledge/troubleshooting/$(date +%F)-short-title.md"
        Or name it by hand: 2026-MM-DD-short-title.md
          - YYYY = year (2026)   MM = month (01-12)   DD = day (01-31)
          - short-title = a few words, dashes-not-spaces (e.g. container-permission-denied)

     2. Replace every  XXX  and every  [ ... ]  with your real words.

     3. Keep it generic: NO secrets, keys, real IPs, or homelab details.

     4. Save it:  git add <the new file>  ->  git commit -m "Troubleshooting: <title>"  ->  git push

     This master lives in git. If it ever gets messed up or deleted:
          git restore knowledge/troubleshooting/_template.md     (or:  git pull)
     ============================================================ -->

> **what:** XXX (the problem in a few words)
> **status:** solved          (or: ongoing)
> **tags:** XXX, XXX          (e.g. docker, permissions)
> **last-used:** YYYY-MM-DD   (change the MM and DD to today)

# XXX — short title of the problem

> **One line (for interviews/resume):**
> "XXX broke — I XXX and XXX (the result)."
> _example: "A container couldn't write its volume — I matched the container's UID
> to the host folder's owner and the app came back up."_

## The problem
XXX — what broke, and when I noticed it (1-2 sentences).

## Symptoms
```
XXX   (paste the exact error line if it's short and has no secrets)
```
XXX — what I actually saw / what it did wrong.

## What I tried
- XXX  ->  XXX (what happened)
- XXX  ->  XXX   <- include the ones that DIDN'T work; it shows how I think

## The cause
XXX — what was actually wrong, once I found it.

## The fix
```
XXX   (the exact commands/steps that solved it — generic, no secrets)
```

## What I learned / how I'm more prepared
- XXX — the takeaway in one line.
- Next time I'll check XXX first, so this is faster / doesn't happen again.

<!-- Before committing:
  [ ] one-line interview version filled in
  [ ] no secrets, keys, real IPs, or homelab details
  [ ] "what I learned" is filled in (the part employers care about) -->
