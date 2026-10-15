> **what:** vmstat — live view of memory, swap, I/O, and CPU so you can tell *why* a box is slow
> **status:** trying
> **tags:** linux, performance, memory, cpu, sysadmin, troubleshooting
> **last-used:** 2026-10-15

# vmstat — virtual memory statistics

## What it is

`vmstat` prints a snapshot of what the whole system is doing right now:
how much memory is free, whether the kernel is swapping to disk, how busy the
disks are, and how the CPU is spending its time. It comes from the
`procps`/`procps-ng` package and reads the numbers straight out of `/proc`, so
it is on almost every Linux box and needs no setup.

The mental model: `top` shows you *per-process* activity (which program is
busy). `vmstat` shows you the *whole machine as one number per column*. When a
server "feels slow," `vmstat` is often the first command you run, because in one
line it tells you which of the four classic bottlenecks you are looking at —
**CPU, memory, swap, or disk I/O**.

## Why it matters on the job

"The server is slow" is the most common ticket a sysadmin gets. The skill the
job is really testing is: can you tell *why*? `vmstat 1` for ten seconds usually
answers it:

- CPU pinned and `r` (run queue) high → you are **CPU-bound**.
- `si`/`so` (swap in/out) constantly non-zero → you are **out of RAM and
  thrashing** (the worst kind of slow).
- `wa` (I/O wait) high and `b` processes blocked → you are **disk-bound**.
- Everything idle but users still complain → the problem is **not this box**
  (network, database, upstream service).

Being able to say that in 30 seconds, with evidence, is what separates someone
who guesses from someone who diagnoses.

## How to run it

The most useful form takes two numbers:

```
vmstat [delay] [count]
```

- `delay` — seconds between reports (e.g. `2` = refresh every 2 seconds).
- `count` — how many reports to print, then stop (e.g. `20`). Omit it and it
  runs until you press Ctrl-C.

**Important:** the *first line* vmstat prints is an average since boot, not
"right now." Ignore it. The second line onward is the live data. This trips up
almost everyone at first.

Handy flags:

- `-t` — add a timestamp column (so you can line results up with a log).
- `-w` — wide output, so columns stay aligned on busy systems.
- `-S M` — show memory fields in megabytes instead of kilobytes (easier to read).
- `-s` — one-shot table of event counters and memory totals (no live loop).
- `-d` — per-disk summary (reads, writes, sectors).
- `-m` — slab layer (kernel object caches); rarely needed day to day.

## How to read the output

A typical live line has these column groups:

```
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs  us sy id wa st
```

- **procs**
  - `r` — processes *wanting* CPU (run queue). If `r` stays above your number of
    CPU cores, tasks are waiting for CPU → CPU-bound.
  - `b` — processes blocked waiting on I/O. Steadily above 0 → disk/network wait.
- **memory** (kB unless `-S M`)
  - `free` — unused RAM. Low `free` alone is **not** a problem on Linux.
  - `buff` / `cache` — RAM Linux uses to cache files. This is *good*; the kernel
    hands it back when programs need it. Beginners panic at "low free memory"
    when `cache` is large — don't.
- **swap**
  - `si` — memory swapped *in* from disk. `so` — swapped *out* to disk.
  - If `si`/`so` are regularly non-zero, you are short on RAM and paying a huge
    speed penalty. This is the single most important thing `vmstat` tells you.
- **io**
  - `bi` — blocks read from disk. `bo` — blocks written to disk.
- **system**
  - `in` — interrupts per second. `cs` — context switches per second. Very high
    `cs` can mean too many threads fighting over the CPU.
- **cpu** (percentages, add up to 100)
  - `us` — user time (your programs). `sy` — system/kernel time.
  - `id` — idle. `wa` — waiting for I/O (disk). High `wa` = disk is the
    bottleneck. `st` — "stolen" time, time a VM wanted but the hypervisor gave
    to someone else (seen on cloud/VPS; high `st` means a noisy neighbour).

## Common mistakes

- **Reading the first line as current.** It is the since-boot average. Always
  look at the second line onward.
- **Panicking about low `free`.** Add `buff` + `cache` back mentally — that RAM
  is available. Only `si`/`so` churn signals a real memory shortage.
- **Running it once.** A single snapshot hides spikes. Run `vmstat 1` and watch
  for 10–20 seconds to see the pattern.
- **Confusing `b` (blocked) with `r` (runnable).** `r` = waiting for CPU,
  `b` = waiting for disk/network. They point at different bottlenecks.

## Does it need root?

No. `vmstat` reads system-wide counters from `/proc` that any user can see, so
you do not need `sudo` for normal monitoring. (`-m`, the slab view, may show
less detail as a regular user on hardened systems, but you rarely need it.)
