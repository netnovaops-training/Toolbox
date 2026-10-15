> **what:** nmap — map a network: which hosts are up and which ports/services they expose
> **status:** trying
> **tags:** networking, nmap, scanning, ports, services, recon, root
> **last-used:** 2026-10-15

# nmap — network mapper

## AUTHORIZATION FIRST (read this twice)

> **Scanning is intrusive, and scanning systems you don't own can be illegal —
> full stop.** A port scan is not "just looking"; it sends packets to someone
> else's machines, it shows up in their logs, and in many places it is treated
> as an attack or an intrusion attempt regardless of intent. Only ever scan:
>
> - machines **you own** (your own laptop, your own lab VMs), or
> - a network you have **explicit, written permission** to test, or
> - the hosts nmap's makers provide for practice (e.g. `scanme.nmap.org`,
>   which they explicitly allow — and even then, gently and rarely).
>
> Everything in this lesson uses `localhost`, your own lab subnet
> (`192.168.1.0/24` as a placeholder), or that sanctioned practice host. Do your
> real learning inside a throwaway VM/lab you control. When in doubt, don't scan.

## What it is

`nmap` ("network mapper") answers two questions at scale: **which hosts on a
network are alive**, and **which ports are open on them (and what service is
behind each port)**. Where `nc` checks one port at a time, `nmap` is built to
sweep ranges of hosts and ports efficiently and summarise the result. It is the
standard tool for inventorying a network — "what's actually out there, and what
is it running?"

The mental model: imagine walking down a corridor of doors (ports) on each
building (host). `nmap` knocks on the doors you ask about and notes which ones
answer, which are shut, and which are behind a guard (a firewall). Then, if you
ask, it listens to what each open door says to guess the service and version.

## The networking concept behind it

A host exposes services on **ports**. `nmap` discovers them by sending crafted
packets and interpreting the replies:

- A TCP **SYN** to an open port gets a **SYN-ACK** back (open).
- A SYN to a closed port gets a **RST** (closed).
- A SYN that gets *no reply* usually means a firewall is **dropping** it
  (filtered).

That open / closed / filtered distinction is the heart of it, and it's the same
handshake you watched in the `tcpdump` lesson — nmap just automates sending the
SYN and reading the answer across thousands of ports. Understanding *why* a port
reads "filtered" (silent drop) versus "closed" (active RST) is exactly the kind
of reasoning an infra/sysadmin job expects.

## Key options

- `-sn` (older `-sP`) — **ping scan**: just find which hosts are up, don't scan
  ports. Good first step to inventory a subnet.
- `-sS` — **SYN scan**: the default fast TCP scan (needs root).
- `-sT` — **TCP connect scan**: completes the full handshake; works without root
  but is slower and noisier.
- `-sU` — **UDP scan** (slow; UDP gives less feedback).
- `-p` — which ports: `-p 22,80,443`, `-p 1-1024`, `-p-` for all 65535.
- `-F` — **fast**: scan only the ~100 most common ports.
- `--open` — show only ports that are open (hide closed/filtered clutter).
- `-sV` — **service/version detection**: probe open ports to name the software.
- `-O` — OS detection (needs root; a guess, not a certainty).
- `-T0`..`-T5` — **timing**: T0 is paranoid-slow, T4 is a common fast-but-sane
  choice on your own network. Higher = faster and louder.
- `-oN/-oG/-oX file` — save output as normal / greppable / XML.
- `-sC` / `--script` — run **NSE** scripts (the Nmap Scripting Engine) for deeper
  checks. Powerful, but many scripts are intrusive — use only with authorisation.

## Reading the output

```
Nmap scan report for 192.168.1.50
Host is up (0.00042s latency).
PORT    STATE    SERVICE  VERSION
22/tcp  open     ssh      OpenSSH 8.9
80/tcp  open     http     nginx 1.24
443/tcp closed   https
8080/tcp filtered http-proxy
```

- **open** — a service is listening and accepting connections.
- **closed** — the host replied, but nothing is listening there (port reachable,
  service absent).
- **filtered** — no reply; a firewall is almost certainly dropping the probe.
  (open = door answers, closed = host says "no one home," filtered = a guard
  silently swallows the knock.)
- With `-sV`, the SERVICE and VERSION columns name the software — the detail you
  use to check for outdated, vulnerable versions during an authorised audit.

## Common uses on the job

```bash
# 1) Which hosts are alive on my own lab subnet? (inventory, no port scan)
sudo nmap -sn 192.168.1.0/24

# 2) Quick look at common open ports on ONE host I own:
sudo nmap -F --open 192.168.1.50

# 3) My own host, full handshake scan without root:
nmap -sT --open 127.0.0.1

# 4) Identify the services/versions on specific ports of a host I own:
sudo nmap -sV -p 22,80,443 192.168.1.50

# 5) The sanctioned public practice target (gently!):
nmap -F scanme.nmap.org
```

> The book includes an aggressive multi-script web-attack recipe (dozens of
> `http-*` NSE scripts, piping output into other attack tools). That is
> offensive security tooling and is **deliberately left out of this lesson**.
> If you go into security work, you'll learn NSE properly, in a lab, against
> targets you're authorised to test — not from a copy-paste one-liner.

## More options that matter on the job

- `-iL hosts.txt` — read targets from a **file** (one host/CIDR per line). The
  standard way to scan an inventory you maintain in text. `--exclude 192.168.1.1`
  keeps the gateway (or anything fragile) out of the sweep.
- `--top-ports 20` — scan the N most common ports instead of a fixed list; a
  good "quick but meaningful" default on your own hosts.
- `-Pn` — **skip host discovery** and scan anyway. Needed when a host is up but
  drops pings (many firewalled boxes), otherwise nmap decides it's down and never
  scans it. Flip side: on a dead host it wastes time, so use deliberately.
- `--reason` — add a column explaining *why* nmap called a port open/closed/
  filtered (e.g. `syn-ack`, `reset`, `no-response`). Turns a verdict into
  evidence you can defend.
- `--open` — hide the noise; show only open ports.
- `-sC` / `--script safe` — run the **safe** category of NSE scripts (banner
  grabbing, read-only checks) on your own hosts. Stay in the `safe`/`default`
  categories for learning; intrusive categories are for authorised security work.
- `--script-help nmap-scripts` and `ndiff` (compare two scans) are worth knowing:
  `ndiff` shows what changed between a baseline scan and today's — the basis of
  simple "did a new port open on our server?" monitoring.

## The greppable-output workflow (the classic combine)

The most job-relevant nmap habit is saving machine-readable output and mining it
with lesson-04 tools, so a scan becomes a list you can act on:

```bash
# -oG - sends greppable output to stdout; pull out host + open ports with awk:
sudo nmap -F --open -oG - 192.168.1.0/24 \
  | awk '/Ports:/ {print $2, $0}' | sed 's/Ignored.*//'

# Just the IPs that have port 22 open, ready to feed into an ssh loop:
sudo nmap -p22 --open -oG - 192.168.1.0/24 \
  | grep '22/open' | awk '{print $2}'

# Save a baseline, scan again tomorrow, and diff to spot new/closed ports:
sudo nmap -F -oX /tmp/baseline.xml 192.168.1.50
#   ... later ...
sudo nmap -F -oX /tmp/today.xml 192.168.1.50
ndiff /tmp/baseline.xml /tmp/today.xml
```

That `nmap -oG - | grep open | awk '{print $2}'` → feed to an `ssh`/`nc` loop
pattern (lessons 01-02) is exactly how small inventories get built and checked in
the real world — always, of course, against hosts you own.

## Common mistakes

- **Scanning something you don't own.** The number-one mistake, and the one with
  legal consequences. Re-read the authorisation box.
- **Running `-sS`/`-O` without root** and being confused when it errors or
  silently falls back. Use `sudo`, or use `-sT` for an unprivileged scan.
- **Trusting "closed" vs "filtered" carelessly.** They mean different things
  (active refusal vs silent drop) and point at different causes.
- **Cranking timing to `-T5` on a fragile network** and causing problems.
  `-T4` is plenty on your own LAN; slower is kinder.
- **Treating `-sV`/`-O` as gospel.** They are educated guesses from fingerprints,
  not certainties.

## Does it need sudo/root?

For the powerful modes, **yes**. SYN scan (`-sS`), OS detection (`-O`), and raw
UDP scanning need root because they craft raw packets. The unprivileged
`-sT` (TCP connect) scan works as a normal user because it uses the ordinary
connect() call — slower and more visible, but no root needed. As with `tcpdump`,
the reason it needs root is that it reaches below the normal per-process network
API to build packets directly.
```
