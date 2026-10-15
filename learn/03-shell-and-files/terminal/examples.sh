#!/usr/bin/env bash
# One-liners adapted from trimstray/the-book-of-secret-knowledge (MIT).
#
# Shell / terminal basics: redirection, history, job control, built-ins.
# Practice these in a throwaway VM or container, NOT on a server you care about.

# set -euo pipefail makes a script safer:
#   -e  exit on the first failing command
#   -u  error on use of an unset variable
#   -o pipefail  a pipeline fails if ANY stage fails, not just the last
# It is commented out here because we are poking around interactively and want
# to see every line run even if one "fails" on purpose.
# set -euo pipefail

# Make a scratch directory so we never touch real files.
SCRATCH="$(mktemp -d)"
# trap runs the cleanup when the script EXITs for any reason (normal or error).
trap 'rm -rf "$SCRATCH"' EXIT
cd "$SCRATCH"
echo "Working in scratch dir: $SCRATCH"

# --- Branching conditionals ------------------------------------------------
# && runs the right side only if the left side SUCCEEDED (exit code 0).
true && echo "success: the left command exited 0"
# || runs the right side only if the left side FAILED (non-zero exit).
false || echo "failed: the left command exited non-zero"

# --- Redirecting stdout and stderr to separate files -----------------------
# Build a tiny command that prints to BOTH streams so we can see the split.
demo() { echo "this is normal output"; echo "this is an error" 1>&2; }
# 1> sends stdout, 2> sends stderr. Each goes to its own file.
demo 1>stdout.log 2>stderr.log
echo "stdout.log contains:"; cat stdout.log     # normal output only
echo "stderr.log contains:"; cat stderr.log     # error output only

# Send stdout and stderr to the SAME file. The "> file" MUST come before 2>&1,
# because 2>&1 means "copy wherever stdout currently points".
demo >combined.log 2>&1
echo "combined.log contains both streams:"; cat combined.log

# --- Quickly back up a file ------------------------------------------------
echo "config version 1" > app.conf
# cp filename{,.orig} expands to: cp app.conf app.conf.orig  (brace expansion).
cp app.conf{,.orig}
echo "backup made:"; ls -1 app.conf*

# --- Empty a file (truncate to 0 bytes) ------------------------------------
# WARNING: this ERASES the file's contents instantly. Here it is safe (scratch).
>app.conf
echo "app.conf size after truncate:"; wc -c < app.conf   # prints 0

# --- Pass a multi-line string into a file (heredoc) ------------------------
# Everything between the markers goes into the file. >> would append instead.
cat > notes.txt << __EOF__
line one
line two
line three
__EOF__
echo "notes.txt:"; cat notes.txt

# --- Create a directory and cd into it in one step -------------------------
# A reusable shell function. -p makes parents as needed and never errors if the
# dir already exists.
mkd() { mkdir -p "$@" && cd "$@"; }
mkd project/logs
echo "now in: $(pwd)"
cd "$SCRATCH"   # go back to scratch root for the rest

# --- Print a row of characters across the terminal -------------------------
# tput cols = current terminal width; printf pads that many spaces; tr turns
# each space into a #. A quick visual divider.
printf "%$(tput cols 2>/dev/null || echo 40)s" | tr ' ' '#'; echo

# --- Show shell history without the line numbers ---------------------------
# cut -c 8- keeps everything from column 8 on, dropping the leading number.
# (If history is empty in this non-interactive shell, you will just see nothing.)
history | cut -c 8- | tail -n 5 || true

# --- Generate a sequence of numbers ----------------------------------------
# Three ways to count. Pick whichever reads clearest to you.
for ((i=1; i<=10; i+=2)) ; do echo -n "$i "; done; echo   # 1 3 5 7 9
for i in {1..5} ; do echo -n "$i "; done; echo            # 1 2 3 4 5
seq -w 5 10 | tr '\n' ' '; echo                           # zero-padded 05..10

# --- Backgrounding and keeping subprocesses alive --------------------------
# NOTE (no change to your system): in a real session you would run a slow job,
# press Ctrl-Z to suspend it, then `bg` to continue it in the background, and
# `disown -a` so it keeps running after you log out. We only describe it here
# because backgrounding an interactive job does not make sense inside a script.
echo "Job control (Ctrl-Z, bg, disown -a) is interactive — try it live in a VM."

# $$ is the PID of THIS shell. Useful in scripts; printing it is harmless.
echo "This shell's PID is $$"

# --- See output AND save it at the same time (tee) -------------------------
# A plain > can't show you the output and keep a copy; tee does both. It sits
# in the middle of a pipe, copying stdin to the file AND passing it along.
echo "== tee: screen + file together =="
demo2() { echo "line A"; echo "line B"; }
demo2 | tee saved.log                 # shows A and B, and writes them to saved.log
echo "saved.log holds:"; cat saved.log
# -a APPENDS instead of overwriting — how you grow an install/run log safely.
demo2 | tee -a saved.log >/dev/null
echo "after append, saved.log has $(wc -l < saved.log) lines"

# --- Exit codes and $? ------------------------------------------------------
# Every command sets $? (0 = success). This is how scripts make decisions.
echo "== exit codes =="
true;  echo "true  -> \$? = $?"        # 0
false; echo "false -> \$? = $?"        # 1
# In a pipeline, $? is only the LAST stage... unless pipefail is on.
false | true; echo "false|true -> \$? = $? (last stage won)"
# PIPESTATUS remembers every stage, which is why real scripts use pipefail.
false | true; echo "PIPESTATUS was: ${PIPESTATUS[*]}"

# --- Process substitution: diff two commands' OUTPUT -----------------------
# <(...) turns a command's output into a throwaway file descriptor, so diff can
# compare two live outputs. Daily use: compare config across two hosts.
echo "== diff the output of two commands =="
printf 'alpha\nbravo\ncharlie\n' > hostA.txt
printf 'alpha\nbravo\ndelta\n'   > hostB.txt
# Here we diff sorted views of each file without creating temp sorted files:
diff <(sort hostA.txt) <(sort hostB.txt) || echo "   (differences shown above)"

# --- Here-string: feed one string as stdin ---------------------------------
# <<< is lighter than a heredoc when you just need one line of input.
echo "== here-string into wc =="
wc -w <<< "count the words in this line"   # prints 6

# --- Safe loop over find results (NUL-separated) ---------------------------
# WARNING (no change here — just echoes): filenames can contain spaces/newlines.
# -print0 + xargs -0 split on NUL instead of whitespace, so odd names survive.
echo "== find -print0 | xargs -0 (safe filename handling) =="
mkdir -p oddnames
touch "oddnames/has a space.txt" "oddnames/normal.txt"
find oddnames -type f -print0 | xargs -0 -n1 echo "would process:"

# --- Keeping a job alive after logout (described, not run) -----------------
# NOTE (no change): for real long jobs you would use one of these so the job
# survives the terminal closing or SSH dropping:
#   nohup ./long-job.sh &          # ignores hangup, logs to nohup.out
#   setsid ./long-job.sh           # detaches into its own session
#   tmux new -s work               # a reattachable session (the real answer)
echo "Long-lived jobs: nohup / setsid / tmux — try tmux live in a VM."

# The trap above cleans up $SCRATCH automatically when we exit here.
echo "Done. Scratch dir will be removed on exit."
