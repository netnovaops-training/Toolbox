# START HERE — my learning path

> **what:** the order to work through my Toolbox lessons
> **status:** in-progress
> **tags:** learning, path, timeline
> **last-used:** 2026-10-15

This is a timeline. Work **top to bottom**. Each lesson is about **4–5 hours**:
read the `doc.md` for each tool, run its `examples.sh` **in a throwaway VM or
container**, then do the lesson's `practice.md`. Ask my mentor when I'm stuck.

Each tool has a pair: **`doc.md`** (understand it) + **`examples.sh`** (real
commands to run). The commands come from the book, adapted and commented.

## Foundation (do early)

- **[07-git-and-version-control](07-git-and-version-control/)** — git the way it
  finally makes sense. I commit my learning as I go, so get comfortable here first.

## The path

**Networking first**
1. **[01-network-connect](01-network-connect/)** — `ssh`, `curl`, `dig` — reach and talk to other machines.
2. **[02-network-capture-and-scan](02-network-capture-and-scan/)** — `netcat`, `tcpdump`, `ngrep`, `nmap` — see and map traffic (own network only).

**Then the command line**
3. **[03-shell-and-files](03-shell-and-files/)** — `terminal`, `find`, `lsof` — move around, find things, see open files/ports.
4. **[04-text-processing](04-text-processing/)** — `grep`, `sed`, `awk`, `perl` — search and reshape text (the real daily skill).

**Then systems**
5. **[05-system-and-performance](05-system-and-performance/)** — `vmstat`, `strace`, `fuser` — what a box is doing and why it's slow.
6. **[06-security-and-crypto](06-security-and-crypto/)** — `openssl`, `gpg` — certs, keys, encryption.
7. **[08-permissions-and-root](08-permissions-and-root/)** — permissions, users, sudo/root, and container permission troubles. A core sysadmin skill — expect it in interviews.

## Reference & docs (the dense stuff — scan it so I don't miss anything)

- **Cheat sheets** — `../knowledge/cheatsheets/`
  - `linux-cheatsheet.md`, `powershell-cheatsheet.md`, `git-cheatsheet.md`
  - **`fork-quick-reference.md`** — all the tools I didn't make full lessons for
    (one/two-liner tools). Each links back to the book to **learn more**.
- **Reference links** — `../knowledge/documents/reference.md` — the book's big
  chapters (tools lists, tutorials, reading) linked, not copied.
- **Guides** — `../knowledge/notes/`
  - `toolbox-how-to.md` — how I grow this toolbox.
  - `github-pr-workflow.md` — the safe branch → PR → merge route.
- **Roadmap** — `../SKILLS.md` — the bigger skills map toward the job.
- **Starters** — `../dev/bash/linux-starter.md`, `../dev/powershell/windows-starter.md`, `../infra/networking/commands.md`.

## Want a tool that isn't a lesson here?

Check `fork-quick-reference.md` first, then open the full book at
`D:\the-book-of-secret-knowledge` (or the fork on GitHub) and copy what's useful
into the right Toolbox folder — with a note and its MIT credit.
