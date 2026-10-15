> **what:** Practice exercises for system diagnosis — vmstat, strace, fuser
> **status:** trying
> **tags:** linux, performance, debugging, processes, practice, sysadmin
> **last-used:** 2026-10-15

# Practice: diagnosing a system (vmstat, strace, fuser)

These tools inspect a live, running system, and some can send signals that stop
processes. **Do every one of these in a throwaway VM or container**, never on a
machine or server you care about. A quick disposable sandbox:

```bash
# Example only — any throwaway Linux VM/container works.
docker run --rm -it --cap-add=SYS_PTRACE ubuntu:latest bash
# (SYS_PTRACE lets strace attach inside the container; install tools with apt.)
```

Work from easy to hard. Try each before peeking at the hint. The point is for
your hands and your eye to learn the patterns, not just to read them.

---

## 1. Read the machine in one glance (easy)

Run a live `vmstat` that refreshes every 2 seconds, prints 5 reports then stops,
with a timestamp on each line. Then state, out loud, which line you should
*ignore* and why.

**Hint:** Two numbers after the command (delay, count) and one flag for the
timestamp. The very first line vmstat prints is special.

**Check yourself:** You printed 5+1 lines, and you can explain that the first
line is the since-boot average, so you read from the second line onward.

---

## 2. Spot the bottleneck (easy)

With `vmstat 1` running, open a second terminal and make the box busy (e.g.
`yes > /dev/null &` to burn CPU, or `dd if=/dev/zero of=~/bigfile bs=1M
count=2000` to hammer the disk — remove the file after). Watch which column
moves.

**Hint:** CPU work shows up in the `us`/`sy` columns and the `r` run queue.
Disk work shows up in `bi`/`bo` and the `wa` (I/O wait) column.

**Check yourself:** You can name, from the columns alone, whether you created a
CPU load or a disk load — and you deleted the big file afterwards.

---

## 3. Is it a memory problem or not? (medium)

Using one `vmstat` run, decide whether your sandbox is short on RAM. Explain why
"low `free`" by itself does not prove a memory shortage.

**Hint:** Look at `si` and `so`, not just `free`. Think about what `buff` and
`cache` are and who gets that memory back when needed.

**Check yourself:** You can say that healthy Linux keeps `free` low on purpose
(it caches files), and that the real red flag is sustained non-zero `si`/`so`.

---

## 4. Find why a command can't open a file (medium)

Run a command that reads a file which does not exist (e.g. `cat
/etc/does-not-exist`) under `strace`, filtering to just the file-open calls.
Find the exact line that reveals the failure.

**Hint:** `-e trace=openat` cuts the noise. Scan the right-hand side of the
output for `= -1` and a capitalised error name.

**Check yourself:** You can point to the `openat(... ) = -1 ENOENT` line and
explain that `ENOENT` means "no such file," which is the whole bug.

---

## 5. Where does the time go? (medium)

Trace a command that does a lot of file work (e.g. `ls -R /usr`) with strace's
summary mode, and read off which single system call was called the most times.

**Hint:** `-c` suppresses per-call output and prints a tally at the end. Send it
to a file with `-o` so it's easy to read.

**Check yourself:** You have a table sorted by time/calls and can name the top
syscall (often something like `getdents64` or `newfstatat` for a directory walk).

---

## 6. Follow the children (harder)

Trace a command that forks a child (e.g. `sh -c 'echo hi'`) and prove that
*without* follow-forks you miss the child's activity, then *with* it you see it.

**Hint:** The flag is `-f`. Run once without it and once with it, filtering to
`-e trace=write`, and compare whether you see the `echo`'s write.

**Check yourself:** You can explain in one sentence why most real services need
`-f` (they fork worker processes you'd otherwise never trace).

---

## 7. Who's holding this file? (harder)

Hold a file open in the background (`tail -f somefile &`), then use `fuser` to
find the PID holding it, in the verbose table form. Then release it cleanly.

**Hint:** `fuser -v <file>` names the holder; the `ACCESS` column shows how it's
held. Stop the background job with `kill %1` or its PID.

**Check yourself:** You read the PID, user, and command from the table, and the
file is released afterward (a second `fuser -v` shows nothing).

---

## 8. "Device is busy" (harder)

Find every process using anything under a directory (simulating a mount you
can't unmount). Use the mount-aware form of `fuser`.

**Hint:** Plain `fuser <dir>` is not enough; you need the flag that treats the
path as a whole filesystem.

**Check yourself:** You used `fuser -mv <dir>` and got a list of every process
touching anything beneath it — the list you'd work through before unmounting.

---

## 9. Who owns the port? (harder)

Start a throwaway listener on a port (e.g. `nc -l 8080 &` in the sandbox), then
use `fuser` to prove which PID owns that port. Clean up afterward.

**Hint:** The target syntax is `port/protocol`, e.g. `8080/tcp`. Add `-v`.

**Check yourself:** `fuser -v 8080/tcp` names your listener's PID; after you
stop it, the same command returns nothing.

---

## 10. Plan a kill before you make it (hardest — think, don't just run)

You found that a stuck process is holding a log file open. Describe the *safe*
sequence to free it, in order, and say which signal you'd try first and why —
before you ever type `fuser -k`.

**Hint:** Look first, choose a polite signal before a forceful one, and confirm
each kill. Think about `-v`, `-i`, `-TERM` vs the default `SIGKILL`, and whether
the service has its own reload/restart command you should prefer.

**Check yourself:** Your plan is (1) `fuser -v` to see what's there, (2) prefer
the service's own reload/stop, (3) if you must signal, `fuser -k -i -TERM`
first, and only escalate to the default KILL if TERM fails — and you can explain
why KILL-first risks data loss.
