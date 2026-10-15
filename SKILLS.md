# Skills roadmap — where I am and what to learn next

My own path toward infrastructure engineer. Each group runs beginner -> deeper.
I have CompTIA Security+ and I'm at a freshman level. One thing at a time.

## Linux
- Move around the shell, files, permissions (see `dev/bash/linux-starter.md`)
- Users, groups, sudo, and file ownership
- systemd: start/stop/enable services, read `journalctl` logs
- Package managers (apt/dnf) and installing software
- Write small bash scripts with variables, loops, and conditionals

## Windows
- PowerShell basics: files, services, processes (see `dev/powershell/windows-starter.md`)
- Users, permissions (NTFS), and running things as admin
- Event Viewer and reading logs
- Scheduled Tasks and basic scripting (.ps1)

## Networking
- IP addressing, subnets, and the gateway/DNS basics
- Tools: ping, dig/nslookup, ss/netstat, traceroute
- Ports and protocols (HTTP/HTTPS, SSH, DNS)
- Reverse proxy and TLS certificates (Caddy/Nginx)
- Read a simple firewall rule set

## Containers
- What an image vs a container is
- Run, stop, and inspect a container (`docker ps`, `logs`, `exec`)
- Write a simple Dockerfile
- docker compose for multi-service setups
- Volumes, networks, and keeping images small

## Security
- Least privilege and managing secrets (never in git)
- SSH keys and hardening logins
- Keeping systems patched and scanning for known issues
- Logging and basic monitoring
- Backups and testing a restore

## Scripting
- Bash: variables, loops, conditionals, functions
- PowerShell equivalents
- Python basics for small automation tasks
- Git for versioning my work (see `knowledge/cheatsheets/git-cheatsheet.md`)
- Reading other people's scripts safely

## Cloud
- Core ideas: regions, VMs, storage, networking
- One provider's free tier, hands-on (spin up and tear down a VM)
- Infrastructure as code: start with a tiny Terraform file
- CI/CD basics: a pipeline that builds and deploys
- Cost awareness and shutting things down
