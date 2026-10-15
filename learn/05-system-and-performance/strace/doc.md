> **what:** strace — watch every system call a program makes, to see *why* it hangs, fails, or can't find a file
> **status:** trying
> **tags:** linux, debugging, syscalls, troubleshooting, sysadmin, security
> **last-used:** 2026-10-15

# strace — trace system calls

## What it is

`strace` runs a program (or attaches to one already running) and prints every
**system call** it makes — every time it opens a file, reads a socket, asks for
memory, or talks to the kernel in any way. A program on Linux cannot touch a
file, the network, or the disk without asking the kernel; `strace` sits between
the program and the kernel and writes down the whole conversation.

The mental model: imagine wiretapping the phone line between an app and the
operating system. You do not need the program's source code, you do not need a
debugger, and you do not need to understand how it was written. You just watch
what it *asks the OS to do* and what answer it gets back.

Each line looks like `syscall(args) = result`. A negative result with a name
like `ENOENT` or `EACCES` is the kernel saying "no," and that one line is very
often the whole bug.

## Why it matters on the job

`strace` answers the questions that stump everyone else:

- **"Why can't the app find its config?"** Trace it and watch the `openat()`
  calls — you'll see the exact wrong path it is looking in.
- **"Why does it fail only in production?"** The failing `open`/`connect` call
  shows a permission (`EACCES`) or missing-file (`ENOENT`) error with the real
  path, no guessing.
- **"Why is it hung?"** Attach to the stuck process; if the last line is a
  `read()` or `connect()` that never returns, you've found what it's waiting on.
- **Security:** you can see exactly what files a program touches and what
  network connections it opens — useful when vetting an unknown binary.

Being able to attach to a live, misbehaving daemon and say "it's blocked on a
read from this socket" is a senior-level move that `strace` makes easy.

## How to run it

Two modes:

```
strace <command> [args]        # launch a program under strace
strace -p <PID>                # attach to an already-running process
```

The flags you will actually use:

- `-f` — **follow forks**: also trace child processes/threads. Most real
  services fork workers, so you almost always want `-f`.
- `-p <PID>` — attach to a running process by PID. Detach with Ctrl-C (the
  program keeps running).
- `-e trace=<set>` — only show calls you care about. Common sets:
  `-e trace=open,openat` (file lookups), `-e trace=network` (sockets),
  `-e trace=bind` (which port it binds). Cuts the noise massively.
- `-o <file>` — write the trace to a file instead of the screen (essential;
  traces scroll fast).
- `-T` — show time spent *inside* each syscall (find the slow one).
- `-t` / `-tt` — timestamp each line.
- `-s <n>` — show up to `n` characters of string arguments (default 32 is often
  too short to see a full path or request; `-s 10000` shows the whole thing).
- `-c` — don't print each call; print a **summary table** at the end: which
  syscalls were made, how many times, and total time each. Great for "where is
  the time going?"

A classic combo: attach to every worker of a service and watch only network
activity with full strings:

```
strace -f -e trace=network -T -s 10000 -p <PID>
```

## How to read the output

- `openat(AT_FDCWD, "/etc/app/config.yml", O_RDONLY) = -1 ENOENT (No such file
  or directory)` — the app looked there and the file isn't there. Fix the path
  or create the file.
- `... = -1 EACCES (Permission denied)` — the file exists but the user running
  the program can't read it. Fix ownership/permissions.
- `connect(3, {sa_family=AF_INET, sin_port=htons(5432), ...}) = -1 ECONNREFUSED`
  — it tried to reach a service (here port 5432) and nothing answered. The
  dependency is down or the address is wrong.
- A line that just stops with no `=` result, and strace sits there — that is the
  call the program is **currently blocked in**. That's your hang.

The pattern to train your eye on: scan down the right-hand side for `= -1` and a
capitalised error name. That is almost always the line that matters.

## Common mistakes

- **Forgetting `-f`.** You trace the parent, it forks a worker, and all the
  interesting activity happens in the child you aren't watching. Use `-f` for
  anything that forks.
- **Drowning in output.** Full traces are enormous. Narrow with
  `-e trace=...` and/or send to `-o file` and grep it.
- **Short strings hiding the answer.** The default truncates arguments; add
  `-s 10000` when you need to see a full path or payload.
- **Running it in production carelessly.** `strace` pauses the target on every
  syscall, so it **slows the traced process down** — sometimes a lot. On a busy
  production daemon, trace briefly, narrow the syscall set, and detach.

## Does it need root?

To attach (`-p`) to a process **you own**, usually no. To attach to a process
owned by *another* user (e.g. a system daemon running as `www-data` or `root`),
you need `sudo`. Many hardened systems also restrict `ptrace` (the kernel
feature strace uses) via `kernel.yama.ptrace_scope`, which can block attaching
even to your own children without privileges. Launching a *new* command under
strace as yourself needs no root.

> WARNING: `strace` slows down and briefly pauses whatever it traces. Do not
> attach to a critical production process for long; narrow with `-e trace=...`,
> capture what you need, then Ctrl-C to detach. Practice in a throwaway VM.
