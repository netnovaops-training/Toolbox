# Jason A. Gibson

**Working toward an infrastructure / systems engineering role.**
I build and run my own systems, break them on purpose, fix them, and write down what I learned.

CompTIA **Security+** · Studying for Network+ / CCNA and Linux+

---

## Projects

### Jun's Garden — self-hosted website, packaged for someone else to run
[github.com/netnovaops-training/garden-for-all](https://github.com/netnovaops-training/garden-for-all)

A complete garden website (plant catalogue, blog, garden tools, Android app) that I
moved from PHP to Rust and then handed over to its owner to run on his own computer.

- Rebuilt the site in **Rust** page by page, keeping every page, address and feature the same.
- Wrote **guided installers** for Ubuntu and Windows that explain each step, plus guides in English and Korean.
- Each program runs in its own **Docker** container; only the front door faces the internet.
- Installs check every file against a published fingerprint list and **stop if anything doesn't match**.
- Set up **security scanning** on every change (CodeQL, Semgrep, Trivy, dependency updates) and worked through every finding.

`Rust` `Docker` `Linux` `PowerShell` `Python` `Kotlin` `GitHub Actions` `Security`

### Toolbox — my working notes, run like a ticket system
[this repo](README.md)

- Every fix, install and project is a **ticket**: its own branch, a write-up, and a pull request.
- A script I built **sorts everything automatically** by topic, language and branch,
  and collects the lessons into one page.
- A step-by-step **learning path** for networking, Linux, security and git, with runnable examples.

`Git` `GitHub Actions` `Bash` `Python` `Markdown`

### Learning lab — practice space
[github.com/netnovaops-training/learning-lab](https://github.com/netnovaops-training/learning-lab)

Where I try things out before they go anywhere else.

---

## Latest work

<!-- BEGIN LATEST WORK -->
_Finished projects appear here automatically._
<!-- END LATEST WORK -->

## See the work

| Page | What it shows |
|---|---|
| [Lessons learned](JACKET.md) | What each project taught me, grouped by technology |
| [Logbook](LOGBOOK.md) | Every write-up, newest first, sorted by topic, language and branch |
| [Problems I've solved](knowledge/troubleshooting/) | Real issues: what broke, how I found it, how I fixed it |
| [Learning path](learn/START-HERE.md) | The lessons I'm working through |

## Skills

| Area | Where to see it |
|---|---|
| **Networking** | [ssh, curl, dig](learn/01-network-connect/) · [tcpdump, nmap](learn/02-network-capture-and-scan/) |
| **Linux** | [shell and files](learn/03-shell-and-files/) · [system and performance](learn/05-system-and-performance/) |
| **Containers** | [Jun's Garden](https://github.com/netnovaops-training/garden-for-all) · [fixing a volume permission error](knowledge/troubleshooting/2026-10-15-container-volume-permission-denied.md) |
| **Security** | Security+ · [permissions and root](learn/08-permissions-and-root/) · [certs and keys](learn/06-security-and-crypto/) |
| **Automation** | [logbook scripts](code/local/) · [GitHub Actions workflows](.github/workflows/) |
| **Git** | [branch and pull request workflow](knowledge/projects/2026-10-15-add-branches-to-flow.md) |
