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

echo "Done. Scratch dir removed on exit."
