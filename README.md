# Toolbox — Jason A. Gibson

My working toolbox and study log on the way to an **infrastructure / systems
engineering** job. I learn by doing: I read something, run it in a lab, break it,
fix it, and write down what stuck. This repo is that process in the open — and my
portfolio while I build the skills.

**👉 [PORTFOLIO.md](PORTFOLIO.md)** — my progress, browsable by skill (networking, Linux, containers, security…).
**📖 [GUIDE.md](GUIDE.md)** — how everything here works, with copy-paste shortcuts.

## How I use it

- **Learn in order** → open [`learn/START-HERE.md`](learn/START-HERE.md). It's a
  timeline: networking first, then the command line, systems, security, and git.
  Each tool has a doc (*what it is, why it matters on the job*) paired with real,
  commented commands to run.
- **Look something up fast** → [`knowledge/cheatsheets/`](knowledge/cheatsheets/).
- **Reuse my code** → [`code/`](code/) — split into what I wrote and what I found useful.

## Layout

| Folder | What's in it |
|---|---|
| **learn/** | The lessons, in the order to work through them (START-HERE.md). |
| **code/** | `mine/` — scripts I wrote. `useful/` — snippets I collected and reuse (credited). |
| **infra/** | Notes by ops topic: networking, containers, security, os, cloud. |
| **knowledge/** | `cheatsheets/`, `notes/` (my guides), `documents/` (links), `cert-prep/`. |
| **ai/** | AI tooling notes (later). |
| **SKILLS.md** | The bigger skills roadmap toward the job. |

## How I work (the habits I'm building)

- Small, clear **git commits** with real messages — my history is a record of my
  growth. (See [`knowledge/notes/professional-git.md`](knowledge/notes/professional-git.md).)
- I run risky things in a **throwaway VM or container**, never on a live box.
- Copied something? It goes in `SOURCES.md` with its licence.
- This repo is **public**, so only generic, reusable material lives here — real
  configs, addresses, and secrets stay private.

Licence: MIT (my work) — see `LICENSE`.
