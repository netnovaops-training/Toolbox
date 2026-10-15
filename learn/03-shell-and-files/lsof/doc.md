# what: lsof — list open files, including network sockets, to see what a process is using
# status: trying
# tags: linux, networking, processes, troubleshooting
# last-used: 2026-10-15

## What this is

`lsof` = **l**i**s**t **o**pen **f**iles. On Linux almost everything is a file:
regular files, directories, pipes, devices, and — importantly — network
connections. So `lsof` answers two huge questions at once:

1. Which process has this file/port open?
2. What files and connections does this process have open?

## Why a sysadmin uses this on the job

- **"Port already in use."** You try to start a service and it refuses because
  something already owns the port. `lsof -i tcp:443` tells you exactly which PID.
- **"What's listening on this box?"** A security and inventory question — you
  want every listening port and the program behind it.
- **"I can't unmount / delete this."** A file or directory is "busy" because a
  process still has it open. `lsof +D /path` finds the culprit.
- **"What's this process actually touching?"** Open log files, config, sockets.

It's a first-reach tool during incidents because it maps the invisible
(connections, locks) back to a concrete process you can inspect or stop.

## Key syntax and flags

`lsof` has many flags; these are the ones that matter most:

- `-i` — show network (internet) files. `-i tcp:443` narrows to TCP port 443,
  `-i udp`, `-i4` for IPv4 only.
- `-P` — show port **numbers** instead of service names (443, not "https").
- `-n` — show **numeric** host addresses (no slow DNS lookups). `-P -n`
  together make output fast and literal.
- `-p <PID>` — only files opened by that process.
- `-c <name>` — only files opened by processes whose command starts with name.
- `-u <user>` — files opened by a user.
- `+D <dir>` — everything open *under* a directory (recursive).
- `-a` — AND the conditions together (by default they are ORed).

A common idiom is `lsof -i -P -n | grep LISTEN` to see only listening sockets.

## How to read the output

Columns you'll see most:

```
COMMAND   PID   USER   FD   TYPE  DEVICE  SIZE/OFF  NODE  NAME
nginx     812   root   6u   IPv4  12345      0t0    TCP   *:80 (LISTEN)
```

- **COMMAND / PID / USER** — who has it open.
- **FD** — file descriptor number (e.g. `cwd` = current working directory,
  `6u` = descriptor 6 open read/write).
- **TYPE** — IPv4, IPv6, REG (regular file), DIR, etc.
- **NAME** — the actual file path, or `host:port (STATE)` for a socket.
- `(LISTEN)` means a server waiting for connections; `(ESTABLISHED)` means an
  active connection.

## Common mistakes

- **Forgetting `-n` and `-P`** — without them `lsof` does reverse DNS and
  service-name lookups, which can hang for seconds on a busy box.
- **Expecting to see *all* processes as a normal user** — you only see your own
  processes' files unless you run as root (see below).
- **Confusing `-i tcp:443` (port) with `-p 443` (PID 443)** — different flags,
  very different results.

## Job-relevant depth

### The states you'll read in a hurry
In the NAME column, `host:port (STATE)` tells the story:
- `(LISTEN)` — a server waiting for connections. This is "what's running here?"
- `(ESTABLISHED)` — a live connection in both directions.
- `(CLOSE_WAIT)` — the other side hung up but your app hasn't closed its socket.
  A pile of these often means a leak/bug in the app, not the network.
- `(TIME_WAIT)` — normal post-close cooldown; lots of them is usually fine.

### The "can't unmount / disk won't free" job
- `lsof +D /mnt/data` — every open file *under* a directory (walks the tree).
- `lsof /mnt/data` — opens on that mount point / device specifically.
- **Deleted-but-held files**: a log you `rm`'d but `df` still shows full. The
  space isn't freed until the holder closes it. Find it with
  `lsof -nP +L1` (the `+L1` means link count < 1 — i.e. unlinked/deleted).
  The fix is to restart or signal the process holding it.

### FD column decoded
- `cwd` current working directory, `rtd` root dir, `txt` the program binary,
  `mem` memory-mapped files, `0u/1u/2u` stdin/stdout/stderr (`u` = read+write,
  `r` read, `w` write). A trailing number like `6u` is descriptor 6.

### Modern alternatives (know them for interviews)
`ss` is the newer, faster socket tool: `ss -tulpn` lists TCP+UDP listeners with
PIDs and numeric ports — the one-liner that's replacing `lsof -i` on Linux. Also
`fuser -k 8080/tcp` to find *and kill* whatever holds a port. Know `lsof`, but
mention `ss` too.

## Reading tricky output

- Empty output as a normal user usually means "those files belong to other
  users — rerun with sudo", not "nothing is open".
- `lsof: WARNING: can't stat() ... file system` on a `/` scan is harmless noise
  from special filesystems; add `2>/dev/null`.
- A socket showing `->` (e.g. `10.0.0.5:443->10.0.0.9:51314`) is local->remote;
  the side with `(LISTEN)` and no `->` is the server.

## Common troubleshooting

- **"Nothing's on the port but the service won't bind."** Something may hold it
  in `TIME_WAIT`, or it's bound to a different interface — check
  `lsof -i -P -n | grep <port>` *with sudo*.
- **"`lsof` hangs for seconds."** You forgot `-n` (DNS) and/or `-P` (service
  lookups). `-nP` makes it instant.
- **"`df` says full, `du` says not."** Classic deleted-but-open file; hunt with
  `lsof -nP +L1`.

## Combine it

`lsof` output is columns, so `grep`/`awk` finish the job:
```
# Every listening port with its program, aligned:
sudo lsof -i -P -n | grep LISTEN | awk '{print $1, $2, $9}' | sort -u | column -t

# Which processes have the most files open (fd-leak hunt), top 10:
sudo lsof -nP | awk '{print $1, $2}' | sort | uniq -c | sort -nr | head

# Just the PIDs holding a port, ready to feed to kill:
sudo lsof -t -i tcp:8080            # -t = terse, PIDs only
# e.g.  kill $(lsof -t -i tcp:8080)   # (preview the PIDs FIRST!)
```
`-t` (terse) is designed to pipe straight into `kill` or `xargs` — but always
print the PIDs first and confirm them before killing anything.

## sudo / root?

As a normal user, `lsof` only shows files and sockets owned by *your* processes.
To see the whole system — every listening port, every other user's open files —
you need **root** (`sudo lsof ...`). These commands only *read* state; they
don't change anything, so they're safe to run, but you still want root for the
full picture.
