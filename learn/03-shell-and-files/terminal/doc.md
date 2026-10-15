# what: the shell/terminal itself — redirection, history, job control, and handy built-ins
# status: trying
# tags: linux, shell, bash, fundamentals
# last-used: 2026-10-15

## What this is

"Terminal" here does not mean one command. It means the shell you type into
(usually **Bash** on Linux servers) and the core moves that make it a real
tool: redirecting output, controlling jobs, managing history, and small
built-in tricks. Everything else in these lessons runs *inside* the shell, so
getting comfortable here pays off everywhere.

When you SSH into a box as a sysadmin, the shell is your whole workplace. You
are not clicking anything. You chain small commands with pipes, send output to
files, background long jobs, and read history to see what the last person (or
you, last week) actually ran.

## Why a sysadmin uses this on the job

- **Redirection** lets you capture a command's output into a log file, or throw
  away noise you don't care about. "Save the full output of this to a file but
  still show me errors on screen" is a daily need.
- **Job control** lets you start something slow, push it to the background, and
  keep working — or leave it running after you log out.
- **History** is your audit trail and your memory. "What command fixed this last
  time?" lives in history.
- **Built-ins** (`cp`, redirection, loops, `trap`) save you from reaching for a
  heavier tool.

## Key ideas and syntax

### Three streams

Every process has three channels:

- **stdin** (0) — input
- **stdout** (1) — normal output
- **stderr** (2) — errors

Redirection sends these somewhere:

- `cmd > file` — stdout overwrites `file`
- `cmd >> file` — stdout appended to `file`
- `cmd 2> file` — stderr to `file`
- `cmd > out.log 2>&1` — stdout to `out.log`, then stderr to the *same place*
- `cmd 2>&1 1>&3 | ...` — advanced splitting (see the example script); the
  numbers are the stream IDs and the order matters.

Reading it: `2>&1` means "make stream 2 (stderr) go wherever stream 1
(stdout) currently goes." Order matters because it copies the *current*
destination.

### Job control

- `cmd &` — start in the background
- `Ctrl-Z` — suspend the foreground job
- `fg` / `bg` — resume in foreground / background
- `jobs` — list background jobs
- `disown -a` — detach jobs from the shell so they survive logout
- `$$` — the PID of the current shell itself

### History

- `history` — numbered list of what you ran
- `HISTFILE` — the file history is saved to; unset it and history won't persist
- `fc -l` — list history (another way)

### Pipes and chaining

- `a | b` — feed a's stdout into b's stdin
- `true && echo ok` — run the right side only if the left *succeeds* (exit 0)
- `false || echo failed` — run the right side only if the left *fails*

## How to read the output

Most of these commands either change a file quietly (no output is good news)
or print a list. For `history`, the first column is the line number; you can
re-run line 42 with `!42`. For job control, `[1]+ Stopped` means job 1 is
suspended, not dead.

## Common mistakes

- `>` **overwrites** — `cmd > important.log` wipes the file first. Use `>>` to
  append when you mean to add.
- `cmd > file 2>&1` works, but `cmd 2>&1 > file` does **not** send stderr to the
  file — the order is wrong. Put the `> file` first.
- Backgrounding with `&` still dies on logout unless you `disown` it (or use
  `nohup`/`tmux`). 
- `kill -9 $$` kills your own shell — handy to drop a session fast, but you lose
  the session immediately.

## Job-relevant depth

### tee — see it AND save it
A daily need: watch output live *and* keep a copy. `>` can't do that; `tee` can.
```
command | tee run.log            # screen + file (overwrite)
command |& tee run.log           # include stderr too (bash 4+; = 2>&1 | tee)
sudo some-install | tee -a install.log   # -a appends instead of overwriting
```
`tee` sits in the middle of a pipe, so the output keeps flowing to the next
stage while a copy lands on disk.

### Here-strings and process substitution
- `cmd <<< "text"` — feed a single string as stdin (lighter than a heredoc).
- `diff <(cmd1) <(cmd2)` — compare the *output* of two commands as if each were
  a file. `<(...)` is a real on-the-fly file descriptor. This is a sysadmin
  favourite: `diff <(ssh host1 'sort /etc/passwd') <(ssh host2 'sort /etc/passwd')`.

### Keeping jobs alive the modern way
`disown` works, but on the job you usually reach for:
- `nohup long-job &` — ignores hangup, writes to `nohup.out`.
- `setsid long-job` — fully detaches into its own session.
- `tmux` / `screen` — the real answer: a session you can detach from and
  reattach to after you log out, or after SSH drops. Learn `tmux` early.

### Exit codes — the thing scripts live and die by
Every command sets `$?` (0 = success, non-zero = failure). This is how shell
logic works. In a pipeline, `$?` is only the *last* command's code unless you
set `pipefail`. `${PIPESTATUS[@]}` holds every stage's code. This is exactly why
`set -euo pipefail` (see below) matters in real scripts.

### set -euo pipefail — the safety header for real scripts
Interactive poking skips it, but a script you commit should start with it:
- `-e` stop at the first failing command (don't plough on after an error).
- `-u` treat an unset variable as an error (catches typos in `$VARNAEM`).
- `-o pipefail` a pipeline fails if *any* stage fails, not just the last.
The example scripts in these lessons comment it out on purpose so every demo
line runs even when one "fails" to make a point — that's a teaching choice, not
how you'd write production scripts.

## Reading tricky output

- `[1]+ Stopped   vim` — job 1 is suspended (Ctrl-Z), not dead; `fg` resumes it.
- `[2] 48213` right after `cmd &` — job number 2, PID 48213.
- `bash: cmd: command not found` is stderr, so `cmd 2>/dev/null` hides it.
- A command that prints *nothing* and returns you to the prompt usually
  succeeded — check `echo $?` to be sure (`0`).

## Common troubleshooting

- **"My redirect made an empty file."** `cmd > file` creates/truncates `file`
  *before* `cmd` runs. If `cmd` then errors, you're left with an empty file and
  the real error on screen. Preview the command first, or capture with `tee`.
- **"The log is empty until the program ends."** Output is buffered when it's
  going to a pipe/file instead of a terminal. Use `stdbuf -oL cmd` or the
  program's own line-buffer/flush option to see logs live.
- **"It died when I closed the terminal."** Backgrounding with `&` isn't enough;
  use `nohup`, `disown`, or `tmux`.

## Combine it

The shell is the glue that joins every other tool in these lessons:
```
# Save full output to a file but still watch errors scroll by:
./deploy.sh > deploy.log 2> >(tee deploy.err >&2)

# Build a pipeline one stage at a time, checking as you go:
grep ERROR app.log | awk '{print $NF}' | sort | uniq -c | sort -nr | head

# Loop find's results safely (NUL-separated, survives spaces in names):
find . -name '*.conf' -print0 | xargs -0 -n1 echo "would process:"
```
`-print0` + `xargs -0` is the safe pattern whenever filenames might contain
spaces or newlines — plain word-splitting breaks on those.

## sudo / root?

None of the basics here need root. Redirecting *into* a system path like
`/etc/profile` does — that is editing a system-wide file, so it needs sudo and
is flagged as a change in the example script. Editing login files wrong can
lock everyone out of a shell, so practice in a throwaway VM.
