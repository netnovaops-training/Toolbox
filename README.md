# Toolbox — Jason A. Gibson

My working collection on the way to infrastructure engineer. Scripts, notes,
cheatsheets and anything useful, organised broad to specific.

This file is the map. Most folders don't need their own README — open them and
read the files. Put a short header on each *item* (see CONVENTIONS.md), not on
folders.

## The map
- **os/** — operating systems
  - `linux/` · `windows/` (`powershell/`, `cmd/`)
- **networking/** — SSH, DNS, Tailscale, curl, ports, firewall
- **containers/** — `docker/` (compose, commands), Kubernetes later
- **cloud/** — AWS / Azure / GCP notes, when I get there
- **ci-cd/** — GitHub Actions, pipelines
- **programming/** — by language: `bash/`, `powershell/`, `python/`, `rust/`,
  `web/` (front end), `mobile/` (Android)
- **databases/** — SQL, MariaDB, Postgres
- **monitoring/** — logs, metrics, uptime
- **security/** — hardening, scanning, how-tos
- **troubleshooting/** — runbooks, "it's slow / it's down" playbooks
- **ai/** — prompts, local AI, tools
- **cheatsheets/** — quick, ADHD-style references (git is here)
- **learning/** — cert prep and things I'm working toward
- **notes/** — anything else

## How I work it
1. Drop a file in the closest folder.
2. Put a short header on top (what / status / tags / last-used — see CONVENTIONS.md).
3. `git add` · `git commit -m "..."` · `git push`. Or add it in the GitHub app.

Licence: MIT (see LICENSE) for what I write. Copied things keep their own
notice — see SOURCES.md. Reusable header: HEADER-TEMPLATE.txt.
