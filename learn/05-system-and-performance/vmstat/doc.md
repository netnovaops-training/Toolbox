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

## A worked example: "the box is slow, fix it"

A ticket says an app server is sluggish. You SSH in and run `vmstat 1`. You read
line two onward and see this pattern:

```
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs  us sy id wa st
 6  2      0  120000  5000 300000    0    0   900  1200  800 2000  30 10  5 55  0
```

Reasoning out loud (this is what an interviewer wants to hear): `wa` is 55 — the
CPU is spending most of its time *waiting for disk*, not computing. `b` (blocked)
is 2, `bi`/`bo` are high → disk is the bottleneck. `si`/`so` are 0, so it is **not**
a RAM shortage. `us`+`sy` is only 40, so it is **not** CPU-bound. Conclusion in one
sentence: "This box is disk-bound, not short on CPU or RAM." Next step: find *what*
is hammering the disk (`iotop`, or `strace -c` on the suspect process to see the
read/write calls). Contrast with a pinned-CPU box: `r` well above your core count,
`us` near 100, `wa` near 0 → chase the busy process with `top`. Contrast with
thrashing: `si`/`so` churning every second, `free` tiny even after adding `cache`
back → the box is out of RAM and paging; add memory or kill the hog.

## Combine it with other tools

`vmstat` prints a table, so the lesson-04 text tools turn it into answers:

- Watch one column live with `awk` (e.g. alert when idle CPU drops):
  `vmstat 1 | awk 'NR>2 && $15+0 < 20 {print "LOW IDLE:", $0}'` — field 15 is `id`.
- Capture evidence for a ticket, then pull only the bad samples:
  `vmstat 1 10 -t > trace.txt` then `awk 'NR>2 && $16+0 > 30' trace.txt` to list
  only the high-`wa` lines (field 16 is `wa`).
- Average a column over a run instead of eyeballing it:
  `vmstat 1 10 | awk 'NR>2 {s+=$15; n++} END{print "avg idle:", s/n}'`.

The habit worth building: a monitoring tool's job is to *produce numbers*; `grep`
and `awk` from lesson 04 are what turn those numbers into a yes/no answer you can
put in a ticket.

## Does it need root?

No. `vmstat` reads system-wide counters from `/proc` that any user can see, so
you do not need `sudo` for normal monitoring. (`-m`, the slab view, may show
less detail as a regular user on hardened systems, but you rarely need it.)
