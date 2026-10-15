#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# strace: watch the system calls a program makes to find why it fails or hangs.
# Tracing only OBSERVES a program; it does not modify files. BUT strace pauses
# and slows whatever it traces, so practice in a throwaway VM/container and
# never attach to a critical production process for long.

set -euo pipefail   # -e stop on error, -u error on unset var, pipefail catch mid-pipe failures

work="$(mktemp -d)"                 # unique scratch dir for trace output files
trap 'rm -rf "$work"' EXIT          # auto-clean the scratch dir on exit

echo "=== 1) Launch a command under strace and watch its file lookups ==="
# -e trace=openat shows only file-open calls; great for "why can't it find X?".
# Watch for lines ending in '-1 ENOENT' (not found) or 'EACCES' (no permission).
strace -e trace=openat cat /etc/hostname

echo "=== 2) Save a full trace to a file instead of flooding the screen ==="
# -o writes to a file; traces scroll fast, so capturing is the norm.
strace -o "$work/ls.trace" ls /tmp >/dev/null
echo "--- first lines of the captured trace ---"
head -n 5 "$work/ls.trace"

echo "=== 3) Summary table: which syscalls, how many, how much time (-c) ==="
# -c prints nothing per-call; at the end it tallies calls and time. Answers
# "where is the time going?" without reading thousands of lines.
strace -c -o "$work/summary.txt" ls -R /usr/share/doc >/dev/null 2>&1 || true
cat "$work/summary.txt"

echo "=== 4) Trace with child processes (follow forks) ==="
# -f follows forked children/threads. 'sh -c' forks, so without -f you'd miss
# the echo running in the child shell. Most real services fork — usually want -f.
strace -f -e trace=write sh -c 'echo hello from a child shell' 2>&1 | grep -i hello || true

echo "=== 5) Put a time limit on a trace ==="
# From the book: wrap strace in `timeout` so an attach can't run forever.
# Here we trace a 2-second sleep but cap the whole thing at 5 seconds.
timeout 5 strace -o "$work/sleep.trace" sleep 2 || true
echo "nanosleep line from the trace:"; grep -i nanosleep "$work/sleep.trace" || true

echo "=== 6) See which port a server binds, then exits cleanly ==="
# -e trace=bind shows the bind() call and the port number it requests.
# We use a short-lived listener and a timeout so nothing stays open.
# (Needs a 'nc' that supports -l; if absent this step just skips.)
if command -v nc >/dev/null 2>&1; then
  # WARNING: this opens a listening socket briefly. Only do it in a throwaway VM.
  timeout 2 strace -f -e trace=bind nc -l 8080 2>&1 | grep -i bind || true
else
  echo "(nc not installed — skipping the bind example)"
fi

echo "=== 7) COMBINE with grep (lesson 04): find the failed file lookup ==="
# strace writes to STDERR, so you MUST redirect 2>&1 before piping, or grep sees
# nothing. Here we trace a 'cat' of a missing file and pull out just the failure.
# This is THE everyday move: "why can't it find its config?" -> grep ENOENT.
strace -e trace=openat cat /etc/does-not-exist.conf 2>&1 | grep ENOENT || true

echo "=== 8) COMBINE: tally every error type a program hits ==="
# Scan the whole trace for error codes (E followed by capitals), then count each.
# A fast way to see 'is this a permissions problem or a missing-file problem?'
# across a noisy run, without reading every line.
strace ls /root /etc /nonexistent 2>&1 \
  | grep -oE 'E[A-Z]+' | sort | uniq -c | sort -rn || true

echo "=== 9) COMBINE: summary table, then read off the heaviest syscall ==="
# -c tallies calls and time. We save it, show the header, and use awk to print
# the single syscall with the most calls (skip the header/footer rows).
strace -c -o "$work/summary.txt" ls -R /usr/share/doc >/dev/null 2>&1 || true
echo "busiest syscall by call count:"
awk 'NR>2 && $1 ~ /^[0-9]/ { if ($4+0 > max) { max=$4+0; name=$NF } } END { print name, "("max" calls)" }' \
  "$work/summary.txt" || true

# --- Patterns from the book you can adapt once you have a real PID ---
# Attach to a running daemon (needs sudo if you don't own it); Ctrl-C detaches:
#   sudo strace -f -p "$(pidof some-daemon)"
# Trace every worker of a forking service, network calls only, full strings:
#   ps auxw | grep '[s]ome-service' | awk '{print "-p " $2}' \
#     | xargs sudo strace -f -e trace=network -T -s 10000
# The [s] trick in the grep stops grep from matching its own process line.
