#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# awk: field-aware text processing — pick columns, filter rows, compute.
# awk only reads and prints; it changes nothing. Practice in a throwaway VM so
# you can experiment freely.

# Safety flags (see terminal/examples.sh). Left off so every demo runs.
# set -euo pipefail

SCRATCH="$(mktemp -d)"
trap 'rm -rf "$SCRATCH"' EXIT
cd "$SCRATCH"

# Sample data with clear columns and a couple of blank/dup lines.
cat > data.txt << '__EOF__'
alice 10.0.0.1 8080
bob   10.0.0.2 9090
carol 10.0.0.3 8080

bob   10.0.0.2 9090
dave  10.0.0.4 7000
this line is intentionally very very very very very very very very long indeed yes
__EOF__

# --- Search matching / non-matching lines ----------------------------------
# /bob/ is the pattern; with no action the default is print. ! negates it.
echo "== lines containing bob =="
awk '/bob/' data.txt
echo "== lines NOT containing bob =="
awk '!/bob/' data.txt

# --- Print matching lines with their line number ---------------------------
# FNR is the line number within this file; $0 is the whole line.
echo "== numbered matches for 10.0.0 =="
awk '/10.0.0/{print FNR, $0}' data.txt

# --- Print a specific column -----------------------------------------------
# $1 is the first field, $NF is the LAST field (NF = number of fields).
echo "== first column (names) =="
awk '{print $1}' data.txt
echo "== last column (ports) =="
awk '{print $NF}' data.txt

# --- Filter rows by a computed condition -----------------------------------
# length($0) is the length of the whole line. Only long lines pass.
echo "== lines longer than 40 characters =="
awk 'length($0) > 40 {print FNR, $0}' data.txt

# --- Remove blank lines -----------------------------------------------------
# NF is the field count; it is 0 (false) on a blank line, so 'NF' keeps only
# lines that have content.
echo "== blank lines removed =="
awk 'NF' data.txt

# --- Remove duplicate lines WITHOUT sorting --------------------------------
# a[$0]++ returns 0 the first time a line is seen (false -> !0 is true -> print)
# and >0 afterwards (true -> !true -> skip). Keeps first occurrence, order kept.
echo "== duplicates removed, original order kept =="
awk '!a[$0]++' data.txt

# --- Reformat columns with labels ------------------------------------------
# printf gives full control over layout. \t is a tab, \n a newline.
echo "== relabelled columns =="
awk '{ printf "user=%s\tip=%s\tport=%s\n", $1, $2, $3 }' data.txt

# --- A quick tally (count per value) in an END block -----------------------
# Build a count array while reading; print it once at the END. Here we count
# how many times each port appears.
echo "== how many lines use each port =="
awk 'NF { count[$3]++ } END { for (p in count) print p, count[p] }' data.txt

# A realistic access log for the harder, job-shaped examples.
cat > access.log << '__EOF__'
10.0.0.1 - - [15/Oct/2026:08:01] "GET /home" 200 531
10.0.0.2 - - [15/Oct/2026:08:05] "GET /app" 200 1200
10.0.0.1 - - [15/Oct/2026:09:02] "POST /login" 401 90
10.0.0.3 - - [15/Oct/2026:09:33] "GET /app" 500 0
10.0.0.1 - - [15/Oct/2026:09:47] "GET /app" 200 1200
10.0.0.2 - - [15/Oct/2026:10:05] "GET /home" 200 531
__EOF__

# --- HARDER: aggregate with END (sum + average) ----------------------------
# $NF is the bytes column here. Accumulate into sum, then report once at END.
# NR is the number of records read, so sum/NR is the average.
echo "== total and average bytes served =="
awk '{ sum += $NF } END { printf "total=%d avg=%.1f over %d requests\n", sum, sum/NR, NR }' access.log

# --- HARDER: sum one column grouped by another -----------------------------
# bytes[ip] += size builds a per-IP total. A sum grouped by key, not just a
# count — the thing a plain uniq -c cannot do.
echo "== bytes served per client IP =="
awk '{ bytes[$1] += $NF } END { for (ip in bytes) print bytes[ip], ip }' access.log | sort -nr

# --- HARDER: field matches a regex, with math ------------------------------
# $1 ~ /regex/ tests the field; here we count only server errors (status 5xx).
echo "== count of 5xx server errors =="
awk '$(NF-1) ~ /^5[0-9][0-9]$/ { n++ } END { print n+0, "server errors" }' access.log

# --- HARDER: pass a shell value in safely with -v --------------------------
# Single quotes stop the shell touching the awk program, so we inject the value
# through -v instead of trying to interpolate it into the quoted script.
echo "== rows for one specific IP (value passed via -v) =="
target="10.0.0.1"
awk -v ip="$target" '$1 == ip { print $0 }' access.log

# --- HARDER: aligned report with printf ------------------------------------
# printf gives column control: %-10s left-justifies the IP, %5d pads the count.
echo "== aligned per-IP request count =="
awk '{ c[$1]++ } END { for (ip in c) printf "%-12s %5d\n", ip, c[ip] }' access.log | sort -k2 -nr

# --- HARDER + COMBINE: the canonical top-N pipeline ------------------------
# awk pulls the field; sort groups; uniq -c counts; sort -nr ranks; head trims.
# Compare with the pure-awk tally above: use the pipeline when you just need
# counts, the array when you also need a sum/average.
echo "== top 3 client IPs by request count =="
awk '{ print $1 }' access.log | sort | uniq -c | sort -nr | head -n 3

# --- HARDER: two-file "join" (NR==FNR trick) -------------------------------
# First file loads keys into an array; 'next' skips to the next line so the
# second file is processed by the final rule, which keeps only matching rows.
echo "== keep only rows whose IP is in the allow-list =="
printf '10.0.0.1\n10.0.0.3\n' > allow.txt
awk 'NR==FNR { ok[$1]; next } ($1 in ok)' allow.txt access.log

echo "Done. Scratch dir removed on exit."
