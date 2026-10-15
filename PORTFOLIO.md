# Jason A. Gibson — building toward infrastructure engineer

> A living, dated record of what I'm learning and the problems I've solved on the way
> to an **infrastructure / systems engineering** role. Everything here is real and
> backed by code and write-ups in this repo.

**Jump to a skill:**
[Networking](#networking) · [Linux](#linux) · [Containers](#containers) · [Security](#security) · [Scripting](#scripting) · [Git](#git) · [Troubleshooting](#troubleshooting)

**Lessons learned, auto-collected:** [JACKET.md](JACKET.md) · every write-up, sorted: [LOGBOOK.md](LOGBOOK.md)

**Certs:** CompTIA Security+ ✅ · targeting Network+/CCNA and Linux+ →
see the [hiring scorecard](knowledge/notes/hiring-scorecard.md)

---

## Recent progress
_Newest first. I add a line here at the end of a day from my [daily log](knowledge/daily-log/)._

- **2026-10-15** — Built a full [learning path](learn/START-HERE.md) (networking → CLI →
  systems → security → git) with runnable, commented examples; wrote up a real
  [container permission fix](knowledge/troubleshooting/2026-10-15-container-volume-permission-denied.md);
  set up a professional git workflow and this portfolio.

---

## Networking
Reach and diagnose hosts from the command line; read DNS, ports, and traffic.
- Lessons: [connect — ssh, curl, dig](learn/01-network-connect/) ·
  [capture & scan — tcpdump, nmap, netcat, ngrep](learn/02-network-capture-and-scan/)
- Quick ref: [networking commands](infra/networking/commands.md)

## Linux
Everyday admin: files, text, processes, performance.
- Lessons: [shell & files](learn/03-shell-and-files/) ·
  [text processing](learn/04-text-processing/) ·
  [system & performance](learn/05-system-and-performance/)
- Cheat sheet: [linux](knowledge/cheatsheets/linux-cheatsheet.md)

## Containers
Run apps in Docker and fix the real gotchas.
- Lesson: [permissions & containers](learn/08-permissions-and-root/containers/)
- Solved: [container volume "permission denied"](knowledge/troubleshooting/2026-10-15-container-volume-permission-denied.md)

## Security
Security+ in practice: least privilege, certs/keys, safe handling.
- CompTIA **Security+** ✅
- Lessons: [security & crypto — openssl, gpg](learn/06-security-and-crypto/) ·
  [permissions, users & root](learn/08-permissions-and-root/)

## Scripting
Automate with bash and PowerShell; reusable, commented code.
- [My code](code/mine/) · [useful snippets I reuse](code/useful/)
- Starters: [linux](code/useful/linux-starter.md) · [windows/powershell](code/useful/windows-starter.md)

## Git
Work like a team: branches, PRs, clean history, no secrets.
- Lesson: [git](learn/07-git-and-version-control/) ·
  Guide: [professional git](knowledge/notes/professional-git.md)

## Troubleshooting
Real problems I solved — the proof I can work an issue end to end.
- [All entries](knowledge/troubleshooting/)
- [Container volume "permission denied"](knowledge/troubleshooting/2026-10-15-container-volume-permission-denied.md)

---
_How to read this: each skill links to the lessons and write-ups that prove it.
New evidence gets added under its skill, and the highlight goes in "Recent progress."_
