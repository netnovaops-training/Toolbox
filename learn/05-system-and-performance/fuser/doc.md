> **what:** fuser — find which process is using a file, directory, mount, or port (and, carefully, kill it)
> **status:** trying
> **tags:** linux, processes, files, ports, troubleshooting, sysadmin
> **last-used:** 2026-10-15

# fuser — who is using this file or port?

## What it is

`fuser` answers one very specific, very common question: **"which process is
holding on to this thing?"** The "thing" can be a file, a whole directory, a
mounted filesystem, or a network port. It prints the process IDs (PIDs) that
have it open.

The mental model: you try to unmount a USB drive and Linux says "target is
busy." *Something* is using it, but what? `fuser` tells you. You try to start a
web server and it says "address already in use." *Something* already owns that
port. `fuser` tells you that too.

It is closely related to `lsof` (list open files). `lsof` is the broad, detailed
tool; `fuser` is the quick, pointed one: "give me the PIDs using exactly this."

## Why it matters on the job

These are everyday sysadmin moments:

- **"Can't unmount, device is busy."** Before you can detach a disk or NFS
  mount, every process using it must let go. `fuser -mv /mnt/data` lists them so
  you know who to stop (or, as a last resort, signal).
- **"Port already in use."** A service won't start because something is already
  on its port. `fuser 443/tcp` (or `8080/tcp`) names the culprit instantly.
- **"A file is locked and I can't replace it."** During a deploy or log rotation,
  `fuser logfile` shows which process still has the old file open.

Knowing *who* holds a resource — before you start killing things blindly — is
the difference between a clean fix and an outage you caused yourself.

## How to run it

```
fuser [options] <name>
```

where `<name>` is a file, directory, or `port/protocol` (like `53/udp`).

Key options:

- `-v` — **verbose**: a readable table with the user, PID, access type, and
  command name. Almost always worth adding.
- `-m <name>` — treat `<name>` as a mount point / filesystem and show *every*
  process using *anything* under it. This is the one for "device is busy."
- `-k` — **kill** the processes using the resource. (See the warning below.)
- `-i` — **interactive**: ask for confirmation before each kill. Pair it with
  `-k` so you don't nuke things by accident: `-ki`.
- `-<SIGNAL>` — send a specific signal instead of the default `SIGKILL`, e.g.
  `-HUP` (reload), `-TERM` (polite stop). Use with `-k`.
- `--list-signals` — print the signal names you can use.

The access-type letters in verbose output tell you *how* a process uses the
file: `f` open file, `r` root directory, `c` current directory, `e` running
executable, `m` mmapped file.

## How to read the output

```
$ fuser -v /var/log/daemon.log
                     USER        PID ACCESS COMMAND
/var/log/daemon.log: root        812 F....  rsyslogd
```

Read it as: the file `/var/log/daemon.log` is held by PID 812, owned by `root`,
which has it open for writing (`F`), and the program is `rsyslogd`. Now you know
that to rotate or delete that log cleanly you should tell `rsyslogd` to reopen
its files (`fuser -k -HUP` or, better, the service's own reload), not just
delete the file out from under it.

For a port:

```
$ fuser -v 443/tcp
                     USER        PID ACCESS COMMAND
443/tcp:             root        990 F....  nginx
```

PID 990 (`nginx`) owns port 443. That's why your new server can't bind it.

## Common mistakes

- **Killing with `-k` before looking.** `-k` defaults to `SIGKILL` (signal 9),
  which gives the process no chance to shut down cleanly — it can corrupt data
  or leave locks behind. Run `fuser -v` first to see *what* you'd kill, then
  prefer `-k -TERM` (polite) over the default, and use `-i` to confirm.
- **Forgetting `-m` for mounts.** Plain `fuser /mnt/data` checks that path as a
  file; `-m` is what walks the whole filesystem for "device is busy."
- **Wrong port syntax.** It's `port/protocol`, e.g. `53/udp`, `80/tcp` — not
  just `80`.
- **Assuming it shows everything.** `fuser` shows processes *you are allowed to
  see*. To see processes owned by other users (most system daemons), you need
  root.

## Does it need root?

For files and ports you own, no. To see processes owned by **other users**
(which is most of the interesting ones — daemons running as root, `www-data`,
etc.) and to **kill** processes you don't own, you need `sudo`. So in practice,
real troubleshooting with `fuser` is usually run with `sudo`.

> WARNING: `fuser -k` sends a signal that can stop or kill processes and lose
> unsaved data — by default it uses SIGKILL, which does not let a program shut
> down cleanly. Always run `fuser -v` first to see what you'd hit, add `-i` to
> confirm each one, and prefer `-TERM` over the default. Practice in a
> throwaway VM/container.
