#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# vmstat: read memory, swap, I/O, and CPU at a glance.
# Everything here is READ-ONLY. vmstat only observes; it changes nothing.
# Practice in a throwaway VM or container so nothing here matters anyway.

set -euo pipefail   # -e stop on error, -u error on unset var, pipefail catch mid-pipe failures

# A scratch dir to save any captured output into (kept off your real files).
work="$(mktemp -d)"                 # mktemp -d makes a unique temp dir, prints its path
trap 'rm -rf "$work"' EXIT          # delete that dir automatically when the script ends

echo "=== 1) Live system utilization: 20 reports, 2s apart, timestamped, wide ==="
# 2 = delay (seconds between reports), 20 = count (how many then stop).
# -t adds a timestamp column; -w = wide so columns line up on busy boxes.
# REMEMBER: the FIRST line is the since-boot average, not "now" — read line 2 on.
vmstat 2 20 -t -w

echo "=== 2) Same idea, megabytes instead of kilobytes, refresh every 5s ==="
# -S M makes the memory fields human-readable (MB). No count = runs till Ctrl-C,
# so here we also cap it with a count of 3 to keep the demo finite.
vmstat 5 3 -w -S M

echo "=== 3) One-shot summary of disk operations (no live loop) ==="
# -D prints totals: how many disks, total reads/writes since boot. Good baseline.
vmstat -D

echo "=== 4) Event counters and memory totals, printed once ==="
# -s is a plain table (forks, boots, memory used/free/cache). Easy to eyeball.
vmstat -s

echo "=== 5) Per-disk activity table ==="
# -d shows reads/writes/sectors per disk device. Spot which disk is busy.
vmstat -d

echo "=== 6) Capture a 10-second trace to a file for a ticket ==="
# Save evidence: 1s interval, 10 samples, timestamped, into the scratch dir.
# Attaching this to a ticket beats saying "it felt slow".
vmstat 1 10 -t -w > "$work/vmstat-trace.txt"
echo "saved trace to: $work/vmstat-trace.txt"
cat "$work/vmstat-trace.txt"

echo "=== 7) COMBINE with awk (lesson 04): watch one column and flag trouble ==="
# vmstat prints a table; awk turns it into a yes/no answer. Field 15 is 'id'
# (CPU idle). 'NR>2' skips the header AND the since-boot first line. Here we
# print any live sample where idle drops below 50% — a cheap "is it busy?" alert.
# (10 samples so the demo ends; the '+0' forces awk to treat the field as a number.)
vmstat 1 10 | awk 'NR>2 { if ($15+0 < 50) print "BUSY:", $0; else print "ok:", $15"% idle" }'

echo "=== 8) COMBINE: capture a trace, then pull only the BAD samples ==="
# Real workflow: record evidence, then grep/awk out just the lines that matter.
# Field 16 is 'wa' (I/O wait). We save a trace, then list only high-wait samples
# — exactly the lines you'd paste into a ticket to prove "it's disk-bound".
vmstat 1 10 -t > "$work/trace.txt"
echo "high I/O-wait samples (wa > 20), if any:"
awk 'NR>2 && $16+0 > 20 { print }' "$work/trace.txt" || echo "   (none — box wasn't disk-bound during the sample)"

echo "=== 9) COMBINE: average a column over the whole run ==="
# Instead of eyeballing, compute the mean idle CPU across the samples. This is
# how you answer "was it busy the whole time or just spiking?" with a number.
vmstat 1 10 | awk 'NR>2 { s+=$15; n++ } END { if (n) printf "avg idle over %d samples: %.1f%%\n", n, s/n }'

# Slab cache view (-m) is intentionally left out of the demo: it is rarely
# needed day to day and prints a very long table. Run `vmstat -m` yourself
# when you specifically want to inspect kernel object caches.
